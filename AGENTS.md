# AGENTS.md

Personal NixOS config flake: **flake-parts + [Den](docs/den.md) + import-tree**. Two hosts, both `x86_64-linux`:
`overlord` (laptop, NVIDIA/zen kernel, user `oxce5`) and `machina-mori` (VM, user `rei`).

## Commands

```bash
nix fmt modules/ flake.nix                   # alejandra — run before committing
nix eval --raw .#nixosConfigurations.overlord.config.system.build.toplevel.drvPath   # ~50s smoke check
nixos-rebuild build --flake .#overlord         # or .#machina-mori
nix build .#machina-mori                       # DOES NOT WORK — no packages.<host> output exists
nix eval .#nixosConfigurations.overlord.config.<option-path>   # targeted verification
nix repl                                       # then :lf . ; .#den is the whole den config
```

- **New files under `modules/` must be `git add`ed before they take effect.** The flake source is
  `git+file://…`, so untracked files are not part of it and import-tree silently skips them — a new
  module that "does nothing" is usually just untracked.
- The flake sets `nixConfig` (substituters + trusted keys). A *fresh* checkout therefore needs
  `--accept-flake-config` once (`nix config set --accept-flake-config` to make it permanent);
  building this flake's own outputs accepts it implicitly.

- The formatter is always **alejandra** (`formatter.x86_64-linux`, see `modules/formatter.nix`) —
  there is no second formatter or lint step. Pass paths: bare `nix fmt` feeds alejandra an empty
  stdin and dies with `unexpected end of file`.
- No test suite, no CI, no lint besides the formatter. `nix flake check` is not set up.
- `SQLite database ... eval-cache ... is busy` warnings are harmless noise.
- `nixpkgs` tracks `github:NixOS/nixpkgs` (unpinned); it was pinned to a commit only because
  vesktop refused to evaluate against newer nixpkgs. `flake.lock` still pins every input, so
  `nix flake update` is still a full rebuild. Watch `den.default.nixos`'s
  `permittedInsecurePackages = [ "electron-40.10.5" ]` — one exact electron version, goes stale
  as soon as nixpkgs moves.
- `den` and `import-tree` come from the **`vic` fork** (`github:vic/den`, `github:vic/import-tree`),
  not `denful` as the README says. Don't "fix" the URLs to upstream.
- `nh` is configured with a hard-coded `flake = "/home/oxce5/.flake"`, so `nh` from this repo
  builds a different path. Use `nixos-rebuild --flake` / `nix build` while working here.

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
- To keep the other machine from rebuilding those, push them to your own cache:
  `nix build .#machina-mori --out-link /tmp/vm && cachix watch chimera-pkgs /tmp/vm`
  (needs a write token — the keys in `modules/cachix.nix` are read-only).
- Check what a change costs before building for real:
  `nix build .#machina-mori --dry-run` → "N paths will be fetched (X GiB download)" vs
  "N derivations will be built". To find *why* something builds from source:
  `nix path-info --store https://cache.nixos.org <store-path>` (exit 0 = substitutable).

## Wiring

- `flake.nix` is only inputs + `flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules)`.
  **Every `.nix` file under `modules/` is auto-imported** — no manual import list. Files/dirs
  starting with `_` are skipped by import-tree.
- `modules/den.nix` is the framework bootstrap: sets `_module.args.__findFile` (enables
  `<chimera/...>` refs), imports `inputs.den.flakeModule`, creates+exports the `chimera`
  namespace, and sets `den.schema.user.includes = [ den._.mutual-provider ]`.
  `flake.den = den` is exported deliberately for `nix repl` debugging — don't remove.
- `modules/default.nix` is `den.default` = config for **all** hosts/users/homes (`stateVersion`
  22.05 NixOS / 26.05 HM, facter import, docs off, dash as `sh`, zram, systemd-boot, permitted
  insecure). Cross-host defaults go here, not into host aspects.
- `modules/formatter.nix`, `modules/nixos-anywhere.nix`,
  `modules/programs/{iosevka-chimera,blender}.nix` are plain flake-parts `perSystem` modules —
  the only non-Den modules. There is **no** `modules/packages.nix`, so the flake exposes no
  `packages.<system>.<host>` and `nix build .#machina-mori` errors; build via
  `nixos-rebuild build --flake .#machina-mori`.

### Aspect naming convention

Aspects live in the exported `chimera` namespace, keyed by file path:

- `modules/networking.nix` → `chimera.networking` (≡ `den.aspects.networking`)
- `modules/pwn/default.nix` → `chimera.pwn`; `modules/pwn/re.nix` → `chimera.pwn.provides.re` (≡ `chimera.pwn._.re`)
- `modules/groups.nix` → `chimera.batteries._.privileged-user` (referenced as `<chimera/batteries/privileged-user>`)
- Class content goes under `nixos` / `darwin` / `homeManager` / `virt` keys; a bare
  `chimera.<x>` key *is* the aspect itself, `provides.<y>` (or `_<y>`) the sub-aspect.

Declaring an aspect does nothing on its own — it must be reached via `includes`:

- `modules/hosts/<host>/default.nix` → `den.aspects.<host>.includes` + `den.hosts.x86_64-linux.<host>`
- `modules/users/<user>.nix` → `den.aspects.<user>.includes` + `den.hosts.x86_64-linux.<host>.users.<user>`
- `modules/machines.nix` → the `chimera.workstation` / `chimera.laptop` / `chimera.vm` **host** role
  aspects that hosts include. Role-as-inheritance: change behavior by editing the role, not each host.
- `modules/roles.nix` → the `chimera.desktop-base` / `chimera.workstation-user` / `chimera.pentest-user`
  **user** role aspects that `den.aspects.<user>.includes` pulls in. Both files are written in the
  literal-`chimera`-attr-path style so they can use `<chimera/…>` strings.

Both host files declare an aspect **and** the matching `den.hosts` entry; Den also auto-creates
`den.aspects.<host>` / `den.aspects.<user>`, so the explicit block is an *extension* of it.
Never delete the `den.hosts.*` line — that is what makes the host get built.

### home-manager

Home-manager is class-based only: `den.schema.user.classes = lib.mkDefault [ "homeManager" ]`
(set once in `modules/den.nix`, so it applies to every user) plus
`den.default.homeManager.programs.home-manager.enable = true`. There are **no `den.homes`
entries**, so the flake exposes `nixosConfigurations.*` but no `homeConfigurations.*`.
Writing a `homeManager` key on an aspect without the user having the class is silently inert.
Per-host HM: `den.aspects.<host>.nixos.home-manager.extraSpecialArgs.*`; HM sees the host config
as `osConfig`.

## Den gotchas that bite here

Read `docs/den.md` (§4, §12) before writing aspects — full reference in-repo.

- Class modules use the **flat form**: `nixos = { pkgs, config, ... }: { … }`. The `...` is
  required; the context-shape split is automatic.
- Convention in this repo: `nixos` class modules assign through `config.` (`config.users.users.… = …`)
  rather than bare option paths. Follow it for consistency.
- A parametric aspect whose entity kind isn't in context is a **silent no-op** — no warning. If
  config "doesn't apply", suspect a `{ user }` / `{ host }` arg at the wrong scope first.
- `excludes` on a parent beats `includes` on a child.
- **`<chimera/...>` path refs and a `chimera` module argument are mutually exclusive in one
  module.** Taking `chimera` as an argument makes path lookup self-referential: `__findFile` stops
  resolving it and Nix falls through to the NIX search path
  (`error: cannot look up '<chimera/...>' in pure evaluation mode`). So a module either takes
  `chimera` and uses explicit `chimera.x.y` refs (see `modules/hosts/*/default.nix`,
  `modules/pwn/default.nix`), or writes `chimera = { … }` as a literal attr path and uses `<chimera/…>`
  strings (see `modules/machines.nix`, `modules/roles.nix`). Under the second style, aspects cannot
  self-reference either — reference siblings by path (`<chimera/desktop-base>`).
- `inputs` is **not** a nixos module arg. To use a flake input inside `nixos = {…}:` content,
  capture it lexically from the outer module args (see `modules/theming.nix`, which threads
  `inputs.chimera-pkgs` into a `pkgs`-taking function).
- An aspect must be a static attrset for `den.reservedKeys`/`settings` to be discoverable.

## Other conventions

- Wrapper binaries: `inputs.wrapper-manager.lib.wrapWith pkgs { basePackage = …; … }`
  (see `modules/pwn/core.nix` for `programs.*.prependFlags`).
- `patches/` holds one patch, applied to the `nixos-anywhere` package in `modules/nixos-anywhere.nix`.
- Local packages come from the sibling flake `chimera-pkgs`; fonts from
  `inputs.chimera-pkgs.packages.${pkgs.stdenv.hostPlatform.system}.iosevka-chimera`.
- Host hardware facts for `overlord` live in `modules/hosts/overlord/_facter.json` (generated by
  `facter`), referenced as `facter.reportPath = ./_facter.json`.
- Cachix keys are inline in `modules/cachix.nix` (public read-only substituter keys).
- Commit style: short lowercase imperative subjects; `formatting` commits are separate.
- Never commit secrets. `modules/secrets/` is currently empty — `sops-nix`/`age` are not wired up.