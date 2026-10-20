# AGENTS.md

Personal NixOS config flake: **flake-parts + [Den](docs/den.md) + import-tree**. Two hosts, both `x86_64-linux`:
`overlord` (laptop, NVIDIA/zen kernel, user `oxce5`) and `machina-mori` (VM, user `rei`).

## Commands

```bash
nix fmt modules/ flake.nix        # alejandra — run before committing
nix eval --raw .#nixosConfigurations.overlord.config.system.build.toplevel.drvPath  # smoke check (~30s warm)
nix eval .#nixosConfigurations.<host>.config.<option-path>                       # targeted verification
nix build .#nixosConfigurations.<host>.config.system.build.toplevel              # build a host's closure
nix path-info .#nixosConfigurations.<host>.config.system.build.toplevel          # already built?
nix repl                          # then :lf . ; .#den is the whole den config
```

- **There is no `nixosConfigurations` package alias.** `nix build .#machina-mori` /
  `nixos-rebuild switch --flake .#machina-mori` are fine, but `nix build .#machina-mori` **errors** —
  the flake has no `packages.<system>.<host>` (only `blender-beta`, `iosevka-chimera`,
  `nixos-anywhere`). To produce a closure without rebuilding the current profile, use the long
  `nixosConfigurations.<host>.config.system.build.toplevel` attrpath above.
- **New files under `modules/` must be `git add`ed before they take effect.** The flake source is
  `git+file://…`, so untracked files are not part of it and import-tree silently skips them — a new
  module that "does nothing" is usually just untracked.
- The flake sets `nixConfig` (substituters + trusted keys). A *fresh* checkout therefore needs
  `--accept-flake-config` once (`nix config set --accept-flake-config` to make it permanent).
- The formatter is always **alejandra** (`formatter.x86_64-linux`, `modules/formatter.nix`) and it
  must be given paths: bare `nix fmt` feeds it empty stdin and dies with `unexpected end of file`.
- `nix flake check --no-build` *does* exit 0 — it evaluates both NixOS configurations and is a
  legitimate quick check. It emits one `unknown flake output 'den'` warning; ignore it
  (`flake.den = den` is deliberate, for `nix repl` — see `modules/den.nix`).
- No test suite, no CI, no lint besides the formatter.
- `SQLite database ... eval-cache ... is busy` warnings are harmless noise.
- `nixpkgs` tracks the `nixos-unstable` channel tarball (`flake.nix`, unpinned; `flake.lock` still
  pins everything, so `nix flake update` is a full rebuild). Watch `den.default.nixos`'s
  `permittedInsecurePackages = [ "electron-40.10.5" ]` — one exact electron version (for `vesktop`),
  it goes stale as soon as nixpkgs moves.
- `den` and `import-tree` come from the **`vic` fork** (`github:vic/den`, `github:vic/import-tree`),
  not `denful` as `README.md:7` says. Don't "fix" the URLs to upstream.
- `programs.nh` is pointed at `/home/oxce5/.flake` (`modules/programs/nh.nix`), which is a **symlink
  to this repo** — so `nh` works here. If that symlink ever changes, `nh` silently builds elsewhere.
- `flake.nix:56-58` claims the `preservation` input is only used by "a skeleton" aspect. That is
  stale — the real content is `modules/impermanence.nix`, wired in through the `vm` host role in
  `modules/assignments.nix`.

## Builds: substitution, not compilation

All builds happen on the **host** (`overlord`); the VM only receives the built system.

- Substituters come from two places that must stay in sync: `nixConfig` in `flake.nix` (applies to
  whoever builds *this flake*) and `modules/cachix.nix` (pushes the same list into each built
  host's `nix.conf`). Forgetting `nixConfig` means a builder that only knows cache.nixos.org and
  starts compiling everything else locally.
- These are **never** substituted — they always compile on the host, don't go bug-hunting:
  `burpsuite` (fhsenv + 700 MB jar), `metasploit-framework`, `rustscan`,
  `rizin.withPlugins [rz-ghidra]` (our override, base `rizin` *is* cached), `neovim`,
  `firefox-esr` (only the policy wrapper; `firefox-unwrapped` is cached), the `dev` outputs of
  `xwayland`/`xwayland-satellite`, `initrd-linux`, plus config-dependent outputs (`dbus-1` session
  files, `fontconfig`, `systemd-hwdb`, `nftables-rules`, `nixos-tmpfiles.d`, home-manager files).
- To keep the other machine from rebuilding those, push to your own cache (needs a **write** token —
  the keys in `modules/cachix.nix` are read-only):
  `nix build .#nixosConfigurations.machina-mori.config.system.build.toplevel --out-link /tmp/vm && cachix watch chimera-pkgs /tmp/vm`
- Check what a change costs before building for real:
  `nix build .#nixosConfigurations.<host>.config.system.build.toplevel --dry-run` → "N paths will be
  fetched" vs "N derivations will be built". To find *why* something builds from source:
  `nix path-info --store https://cache.nixos.org <store-path>` (exit 0 = substitutable).

## Wiring

- `flake.nix` is only inputs + `flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules)`.
  **Every `.nix` file under `modules/` is auto-imported** — no manual import list. Files/dirs
  starting with `_` are skipped by import-tree (hence `_facter.json`, `_disk-layout.nix`).
- `modules/den.nix` is the framework bootstrap: `_module.args.__findFile` (enables `<chimera/...>`
  refs), `inputs.den.flakeModule`, the `chimera` namespace + module arg, and
  `den.schema.user.includes = [ den._.mutual-provider ]`. `flake.den = den` is exported deliberately.
- `modules/default.nix` is `den.default` = config for **all** hosts/users/homes (`stateVersion`
  22.05 NixOS / 26.05 HM, facter import, docs off, `defaultPackages = []`, dash as `sh`, zram,
  systemd-boot initrd, permitted insecure). Cross-host defaults go here, not into host aspects.
- `modules/formatter.nix`, `modules/nixos-anywhere.nix`, `modules/programs/{iosevka-chimera,blender}.nix`
  are plain flake-parts `perSystem` modules — the only non-Den modules.
- `patches/` holds one patch, applied to `nixos-anywhere` in `modules/nixos-anywhere.nix`.
- Local packages come from the sibling flake `chimera-pkgs` (`sliver-client`, `netexec`,
  `evil-winrm`, and the `sliver` NixOS module); fonts from
  `inputs.chimera-pkgs.packages.${pkgs.stdenv.hostPlatform.system}.iosevka-chimera`.
- Host hardware facts for `overlord` live in `modules/hosts/overlord/_facter.json` (generated by
  `facter`), referenced as `facter.reportPath = ./_facter.json`.
- Commit style: short lowercase imperative subjects; `formatting` commits are separate.

### Aspect naming convention

Aspects live in the exported `chimera` namespace, keyed by file path:

- `modules/networking.nix` → `chimera.networking` (≡ `den.aspects.networking`)
- `modules/pwn/default.nix` → `chimera.pwn`; `modules/pwn/re.nix` → `chimera.pwn.provides.re` (≡ `chimera.pwn._.re`)
- `modules/groups.nix` → `chimera.batteries._.privileged-user` (referenced as `<chimera/batteries/privileged-user>`)
- Class content goes under `nixos` / `darwin` / `homeManager` / `virt` keys; a bare
  `chimera.<x>` key *is* the aspect itself, `provides.<y>` (or `_<y>`) the sub-aspect.

Declaring an aspect does nothing on its own — it must be reached via `includes`:

- `modules/assignments.nix` is the **only** place roles and entity includes live:
  - `chimera.workstation` / `chimera.laptop` / `chimera.vm` are **host** role aspects; each host
    includes one. Role-as-inheritance: change behavior by editing the role, not each host.
  - `chimera.desktop-base` / `chimera.workstation-user` / `chimera.pentest-user` are **user** role
    aspects; each user includes one.
  - `den.aspects.<host|user>.includes` connects each entity to its role and any one-off aspects.
- `modules/hosts/<host>/default.nix` → hardware/display/host-specific config + `den.hosts.x86_64-linux.<host>`
- `modules/users/<user>.nix` → user-specific config + `den.hosts.x86_64-linux.<host>.users.<user>`

Host files extend the auto-created aspect **and** declare the matching `den.hosts` entry; Den also
auto-creates `den.aspects.<host>` / `den.aspects.<user>`, so the explicit block is an *extension* of
it. Never delete the `den.hosts.*` line — that is what makes the host get built.

Two consequences of that split that are easy to get wrong:

- **`<chimera/pwn>` is included twice** — by the `vm` host role *and* by the `pentest-user` user
  role, both in `modules/assignments.nix`. The `nixos` half (wireshark, `tun0` in the firewall,
  `services.sliver.enable`) reaches machina-mori through the *host* role; only the `homeManager`
  half arrives via the user role. Verified: wireshark is `true` on `machina-mori`, `false` on
  `overlord`. The same reasoning is why `pentest-user` re-includes `<chimera/virt/headless>`
  purely for its `homeManager` half.
- **`virt.docker` (`virtualisation.nix:36-42`) only sets `virtualisation.docker.enable`** — it does
  not add the `docker` group, so `modules/hosts/overlord/default.nix` patches `users.privilegedGroups`
  in by hand. `virt.host` likewise has no `amd_iommu`, so PCI/USB passthrough into the VM isn't set up.

### home-manager

Home-manager is class-based only: `den.schema.user.classes = lib.mkDefault [ "homeManager" ]`
(set once in `modules/den.nix`, so it applies to *every* user — including service accounts like the
`sliver` user that `modules/pwn/c2.nix:9` creates) plus
`den.default.homeManager.programs.home-manager.enable = true`. There are **no `den.homes` entries**,
so the flake exposes `nixosConfigurations.*` but no `homeConfigurations.*`.
Per-host HM: `den.aspects.<host>.nixos.home-manager.extraSpecialArgs.*`; HM sees the host config as
`osConfig`.

## Den gotchas that bite here

Read `docs/den.md` (§4 aspects, §12 gotchas checklist) before writing aspects — full reference
in-repo, and §12 is a dense list worth skimming in full.

- **A `homeManager` key written at host scope is silently dropped.** Not an error, no warning.
  This is live in the repo: the fish `vpn` function at `modules/hosts/machina-mori/default.nix`
  is a `homeManager` key on `den.aspects.machina-mori`, so it does not exist —
  `nix eval .#nixosConfigurations.machina-mori.config.home-manager.users.rei.programs.fish.functions`
  returns only `["y"]` (from `apps/yazi`). To reach users from a host aspect use
  `provides.to-users = {user, ...}: { nixos = …; }`, as `hosts/machina-mori/impermanence.nix:25-51`
  and `virtualisation.nix:30-34` correctly do.
- Class modules use the **flat form**: `nixos = { pkgs, config, ... }: { … }`. The `...` is required;
  the context-shape split is automatic.
- Convention in this repo: `nixos` class modules assign through `config.` (`config.users.users.… = …`)
  rather than bare option paths.
- A parametric aspect whose entity kind isn't in context is a **silent no-op** — no warning. If
  config "doesn't apply", suspect a `{ user }` / `{ host }` arg at the wrong scope first.
- `excludes` on a parent beats `includes` on a child.
- **`<chimera/...>` path refs and a `chimera` module argument are mutually exclusive in one
  module.** Taking `chimera` as an argument makes path lookup self-referential: `__findFile` stops
  resolving it and Nix falls through to the NIX search path
  (`error: cannot look up '<chimera/...>' in pure evaluation mode`). So a module either takes
  `chimera` and uses explicit `chimera.x.y` refs (see `modules/hosts/*/default.nix`,
  `modules/pwn/default.nix`), or writes `chimera = { … }` as a literal attr path and uses `<chimera/…>`
  strings (see `modules/assignments.nix`). Under the second style, aspects cannot
  self-reference either — reference siblings by path (`<chimera/desktop-base>`).
- `inputs` is **not** a nixos module arg. To use a flake input inside `nixos = {…}:` content,
  capture it lexically from the outer module args (see `modules/theming.nix`, which threads
  `inputs.chimera-pkgs` into a `pkgs`-taking function).
- An aspect must be a static attrset for `den.reservedKeys`/`settings` to be discoverable.

## helium (`modules/programs/browsers/helium.nix`)

Split in two halves because **Chromium on Linux reads policy machine-wide only**:
`/etc/chromium/policies/{managed,recommended}`. A policy file under `~/.config/<browser>/policies`
is ignored — `chrome://policy` came back empty while the oxcl HM module was writing exactly that.
So policies and the pinned-extension list are `nixos`; only the package, the `Mod+B` bind and the
external-extension JSON are `homeManager`. Like `<chimera/pwn>`, the aspect is reached twice: a host
role for the nixos half, a user role for the HM half. HM reads the nixos-side list through
`osConfig.programs.helium.extensions`.

What is upstream and what is not:

- Policy file is upstream: `programs.chromium.enable` + `extraOpts` (freeform attrs) makes nixpkgs
  render `chromium/policies/managed/extra.json`, plus copies for `brave/` and `opt/chrome/`.
- `ExtensionsSettings` has **no upstream typed equivalent**. nixpkgs
  `programs.chromium.extensions` exists but is `listOf str` → `ExtensionInstallForcelist` (web-store
  force install). HM `programs.chromium.extensions` does take `{id, updateUrl, crxPath, version}`
  and writes `<configDir>/External Extensions/<id>.json`, but `configDir` is hardcoded to
  `~/.config/chromium` (or the chrome/brave dirs), never Helium's `~/.config/net.imput.helium` —
  hence the `xdg.configFile` write here. This nixpkgs pin has no package-level CRX mechanism either
  (`withPlugins` is gone from `chromium/{common,browser,default}.nix`).
- `programs.helium.extensions` is ours and exists for one thing upstream cannot do: **hash-pinned
  CRX bytes**. `crx.hash` fetches from the store at build time, `crx.path` points at an in-tree CRX;
  the assertion requires exactly one. `id` is `[a-z]{32}`.

Why every entry is `allowed`, never `force_installed`: a force hands the id to Chromium's updater,
which then needs `update_url` to fetch from. A store CRX has no update source, so the force never
lands — observed: the externals installed fine while the one forced external never did. `allowed`
only whitelists the id under the `"*": blocked` catch-all; `external_crx` performs the install.
`update_url` is meaningless under `allowed` and is null on every entry.

Why nothing auto-updates: `external_crx` + `external_version` is a one-shot local install. The
browser only reinstalls when `external_version` changes, i.e. when the repo bumps `crx.version`
(and `crx.hash` together: `nix hash file --type sha256 --base32 <crx>`), followed by a rebuild and a
browser restart. The self-updating key is `external_update_url` (HM's default for a bare
`{id = "…";}`); we never emit it. The Teto theme can never auto-update — it has no update manifest.
The fetch URL pins client params (`prodversion=155.0.8059.84`, …) so the served bytes stay stable;
bump that only together with every hash if the store ever refuses the old client.

`mkCrxJson` must stay a `runCommand`, not `writeText` + `builtins.toJSON`: `toJSON` drops string
context, so the CRX store path in `external_crx` would silently leave the system closure. Through
the runCommand the CRX is a real build input. (Upstream HM's chromium module has this same bug —
it writes `external_crx` with `toJSON`.)

Extension ids: `doojm…` NoScript, `jplg…` Proton VPN, `ghmb…` Proton Pass, `bmel…` Teto theme
(`crx.path`), `gppong…` Wappalyzer, `gckn…` FoxyProxy. `pentest-helium` only appends the last two to
the same list; `base-helium` folds the whole thing into one `ExtensionSettings` dict, so there is a
single unconflicted managed file.

Teto theme: pre-packed by hand with `--pack-extension`. The pack key is deliberately not committed
(it lives in `~/.local/share/helium-pack/pack.pem`); the id is sha256 of that key's SPKI DER with
hex digits mapped 0-f → a-p, so repacking with the same key keeps the id stable.

## VM-specific conventions

- `machina-mori` is a real guest built by this flake, but its **libvirt domain is created by hand in
  virt-manager on `overlord`**. There is no `virtualisation.vmVariant`, no `nixos-generators`, no
  domain XML in the flake — only the guest closure.
- Display config lives in `den.hosts.<host>.displays` (`modules/toplevel/display-properties.nix`).
  machina-mori uses the QEMU virtio-GPU output name `Virtual-1` with `custom = true; refresh = 60.0`
  — `custom` asks niri for a mode the guest GPU never advertises, which is exactly the documented
  use case. Two assertions in `den.default.nixos` require every host to define ≥1 display and
  require `refresh` when `custom` is set.
- A display key is whatever niri knows the output by — copy the name from `niri msg outputs`
  (often a connector like `eDP-1`, but a display can also be named by its EDID, in which case the
  key is a longer string). Such a key must be quoted — unquoted it is a Nix parse error, not a
  module error. `transform` is an `enum` of strings, so `transform = "270";`.
- `wallpaper` is recorded but **nothing applies it** (`awww` takes no image argument, and the
  startup race is unwon). Apply it manually: `awww img /assets/rei.jpeg`.
- Root is fully volatile: tmpfs `/` + `/home`, a 15 G ext4 `/persist` LV, and a disposable btrfs
  `/nix` (`modules/hosts/machina-mori/_disk-layout.nix`). State that must survive is enumerated in
  `hosts/machina-mori/impermanence.nix` — Sliver client config, `.msf4`, nuclei templates, herdr,
  `/workspace`. If you add a tool that keeps state, add it there or lose it on reboot.
- Pentest tooling is opted into deliberately to keep the closure small: `modules/pwn/core.nix`
  overrides `wordlists` down to `lists = [nmap]` (nixpkgs' default pulls `seclists`, ~2 GiB), with
  the big lists behind `chimera.pwn.provides.wordlists`. `chimera.pwn._.forensics` and
  `forensics.imaging` are likewise commented out of the default include list — `guymager` needs
  Qt5 + mono and propagates `qttools`' *dev* output (~2.6 GiB on its own), and `libewf`/`sleuthkit`
  are enough to read E01 images and do timeline work. Don't "helpfully" re-enable them.
- Never commit secrets. `sops-nix`/`age` are **not** wired up — there is no `modules/secrets/`
  directory (it was deleted in `9e31f62`); the only pre-existing secret shape is rei's inline
  `hashedPassword` in `modules/users/rei.nix`.

## Desktop (niri, binds, shells)

- `modules/desktops/niri/binds.nix` groups one navigation action per direction and binds every key
  spelling of that direction under the same prefix (arrows + hjkl). Monitor focus only spells the
  horizontal directions with arrows; hjkl still covers all four.
- **Mod+B is owned by the browser aspect, not by `binds.nix`.** `base-firefox` sets it
  `mkDefault "firefox"`, `pentest` `mkForce`s `"firefox-esr"`, `base-helium`'s homeManager half sets
  `"helium"`. On machina-mori both `pentest` and `pentest-helium` are included through the user role,
  so firefox-esr wins and helium is launched from the launcher only.
- niri `window-rule._children`: a second window-rule block can only be expressed as a *top-level*
  `_children` singleton. A nested `window-rule._children` inlines into one block and merges all
  matches (observed: cast windows forced to 1300x720); a plain list renders invalid `-` nodes.
- Display `custom = true` needs `refresh`; niri computes the timings itself — a separate `modeline`
  node overrides that outright.
- The niri wallpaper daemon is started, but `awww-daemon` takes no image argument: the image is
  pushed imperatively with `awww img …` once the socket exists (startup race, not won).
- `modules/desktops/desktop-shells/dms.nix` is **parked** — nothing includes it; it is kept so dms
  can be swapped back in for noctalia. `modules/theming/declarative.nix` (build-time fallback theme)
  is currently only reached through it, also parked. Noctalia, when present, owns the palette at
  runtime and renders GTK/Qt/terminal/KDE theme files; nothing hardcodes colours in that path.

### firefox

- `<chimera/browser/pentest>` re-includes `base-firefox` and force-installs Wappalyzer + FoxyProxy.
- Dark Reader lives only in the `Personal` profile, so base does not force-install it; it is merely
  whitelisted (`installation_mode = "allowed"`) so the copy already in `Personal` keeps working.

## Misc module notes

- `modules/boot.nix` is shared basics included through the host role (`<chimera/boot>` in
  `chimera.workstation`); hosts should not re-declare it.
- `modules/programs/core.nix`: the second list is desktop-only add-ons — the bigger/duplicate CLIs
  that only earn their closure cost on the laptop.
- `modules/gaming.nix`: OpenTabletDriver needs write access to input devices, hence `uinput`.
- `modules/virtualisation.nix`: `hostUserKey` is trusted on all guests so the host user can ssh in
  as root or any user; it is a placeholder to replace, and per-host overrides use `mkDefault`.
- `modules/hosts/overlord/default.nix`: display keys are output names copied from `niri msg
  outputs`; `HDMI-A-5` is the projector and is deliberately left unpinned (`eDP-1` is the pinned
  panel).

## Parked code

Commented-out blocks are deliberate parking, not leftovers: `boot.nix` (lanzaboote/secure boot),
`networking.nix` (Wake-on-LAN link), `nix.nix` (flake registry), `xdg.nix` (XDG relocation
variables), `syncthing.nix` (a device), `programs/{core,gui}.nix` and `pwn/*` (unused tools). Do not
delete or re-enable them without asking.

## Comments

Keep the long *why* — mechanisms, observed failures, upstream gaps — in this file, not in Nix
modules. In modules, write a short one-line comment wherever a lambda or helper's purpose is not
obvious from its name (`mkCrxJson`, `crxSource`, `vendored`), or where the name alone would mislead.
One line, no paragraphs; anything longer belongs here.
