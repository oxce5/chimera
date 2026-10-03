# Den — Agent Reference

Condensed reference for **Den** (https://den.denful.dev), a context-aware, aspect-oriented
framework/library for NixOS, nix-Darwin and home-manager.

- Source: https://den.denful.dev
- Repo: https://github.com/denful/den
- Docs pages are indexed at the end of this file.
- Snapshot date: 2026-10-03. Den is pre-1.0 ("HeadsUp" / bleeding-edge) — verify API details
  against the live docs before relying on internals.

---

## 1. Mental model (read this first)

Den is a **data-transformation pipeline over infrastructure entities**. Functions are applied at
pipeline points; the function's *argument shape* is the condition.

```
flake
└── flake-system { system }              den.systems
    ├── host { host }                    den.hosts.<system>.<name>
    │   └── user { host, user }          den.hosts.<sys>.<name>.users.<name>
    └── home { home }                    den.homes.<system>.<name>
```

Four concepts:

| Concept | Meaning | Option |
|---|---|---|
| **Entity** | typed data record: host, user, home | `den.hosts`, `den.homes`, `den.schema` |
| **Aspect** | composable unit of config spanning Nix classes | `den.aspects` |
| **Policy** | function from context → effects; defines topology/routing | `den.policies` |
| **Quirk** | named structured data emitted by aspects, aggregated via pipes | `den.quirks` |

Entities declare *what exists*; aspects declare *what it does*; policies decide *how things
relate*; quirks let aspects share data without coupling.

### Context vs NixOS module args — the key distinction

- **Den context** (`{ host }`, `{ host, user }`, `{ home }`) is a pipeline value passed as a
  single attrset argument to a **real Nix function**. It is *not* `specialArgs`, not
  `_module.args`. It is evaluated **before** module evaluation, so it cannot cause infinite
  recursion.
- **NixOS module args** (`{ config, pkgs, lib, ... }`) live inside the module system.

The two can be mixed in one function (see "flat-form class module" below) — Den splits the args
for you via `builtins.functionArgs`.

### Aspect-oriented, not host-first

```nix
# One aspect configures every platform/host.
den.aspects.bluetooth = {
  nixos.hardware.bluetooth.enable = true;
  homeManager.services.blueman-applet.enable = true;
  darwin.homebrew.casks = [ "blueutil" ];
};

den.aspects.laptop.includes  = [ den.aspects.bluetooth ];
den.aspects.desktop.includes = [ den.aspects.bluetooth ];
```

### Context-driven dispatch

```nix
# Runs in every context (host, user, home).
{ nixos.networking.firewall.enable = true; }

# Runs only in a { host } scope. Silently skipped elsewhere.
({ host }: { nixos.networking.hostName = host.hostName; })

# Runs only in a { host, user } scope.
({ host, user }: {
  nixos.users.users.${user.userName}.extraGroups = [ "wheel" ];
})
```

The context shape *is* the condition — no `mkIf`, no `enable` flag.

---

## 2. Quickstart (flake, flake-parts)

### `flake.nix`

```nix
{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.darwin.url = "github:nix-darwin/nix-darwin";
  inputs.import-tree.url = "github:denful/import-tree";
  inputs.den.url = "github:denful/den";
  # optional
  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";

  outputs = inputs:
    (inputs.nixpkgs.lib.evalModules {
      modules = [ (inputs.import-tree ./modules) (inputs.den.flakeOutputs.flake) ];
      specialArgs.inputs = inputs;
    }).config.flake;
}
```

### `modules/den.nix`

```nix
{ inputs, den, lib, ... }: {
  imports = [ inputs.den.flakeModule ];           # provides `den` module arg + den.* options

  den.schema.user.classes = lib.mkDefault [ "homeManager" ];
  den.default.homeManager.home.stateVersion = "25.11";

  den.hosts.x86_64-linux.igloo.users.tux = { };
  den.hosts.aarch64-darwin.mac.users.alice = { };

  den.aspects.igloo = {
    includes = [ den.batteries.hostname ];
    nixos = { pkgs, ... }: { environment.systemPackages = [ pkgs.hello ]; };
  };

  den.aspects.tux = {
    includes = [ den.batteries.define-user den.batteries.primary-user ];
    homeManager = { pkgs, ... }: { home.packages = [ pkgs.vim ]; };
  };
}
```

Build: `nix build .#nixosConfigurations.igloo` / `nixos-rebuild build --flake .#igloo`.

### No-flake variant (`npins` + `with-inputs`)

```nix
# default.nix
let
  sources = import ./npins;
  with-inputs = import sources.with-inputs sources { };
  outputs = inputs:
    (inputs.nixpkgs.lib.evalModules {
      modules = [ (inputs.import-tree ./modules) ];
      specialArgs.inputs = inputs;
    }).config.flake;
in
with-inputs outputs
```

```console
npins init
npins add github denful import-tree   -b main
npins add github denful den            -b main
npins add github denful with-inputs    -b main
npins add github nix-community home-manager --branch master
```

Build: `nixos-rebuild build --file . -A nixosConfigurations.igloo`.

### Layout rules

- `import-tree` auto-imports every `.nix` under `./modules` recursively.
- Files/dirs starting with `_` are **ignored** by `import-tree` (use `_nixos/` for plain
  NixOS modules you `imports` yourself).
- `inputs.den.flakeModule` → the `den` module arg. `inputs.den.flakeOutputs.flake` → the
  flake-parts-compatible `flake` output option (needed when there is no flake-parts and you
  contribute `packages`/`checks`/etc.).
- `inputs.den.flakeModules.strict` → strict typing for `den.schema.{host,user,home,aspect,flake}`
  (undeclared attrs become errors).
- `inputs.den.namespace <name> <export|false|sources>` → aspect namespace.

---

## 3. Reference: entities & schema

### `den.schema`

Schema entries are **metadata modules, not aspects**. They provide shared options to every
entity of a kind. Freeform type ⇒ adding a key registers a new **entity kind**.

| Path | Type | Purpose |
|---|---|---|
| `den.schema.conf` | deferredModule | applied to host, user **and** home |
| `den.schema.host` | deferredModule | applied to all hosts (imports `conf`) |
| `den.schema.user` | deferredModule | applied to all users (imports `conf`) |
| `den.schema.home` | deferredModule | applied to all homes (imports `conf`) |
| `den.schema.aspect` | deferredModule | applied to all aspects; where `den.lib.strict` is applied |

Per-schema-entry attributes:

| Attr | Type | Default | Meaning |
|---|---|---|---|
| `includes` | listOf raw | `[]` | aspects/policies activated for every entity of the kind |
| `excludes` | listOf raw | `[]` | suppressed for every entity of the kind |
| `isEntity` | bool | computed | real entity (fan-out/policy target); set explicitly for content-free kinds |
| `isolated` | bool | `false` | ancestors cannot collect into an isolated scope |
| `parent` | nullOr str | `null` | enclosing entity kind (e.g. `user.parent = "host"`) |
| `collisionPolicy` | nullOr enum | `null` | see collision policy below |

Pre-registered kinds: `host`, `user`, `home`, `conf`, `fleet`. Others are added by batteries or
by you: `flake`, `flake-system`, `wsl-host`, `flake-parts`, `hm-host`, …

### `den.hosts` — `attrsOf systemType`

Keyed `<system>.<name>`; the flat form `den.hosts.<name> = { system = …; }` is normalised to
the same thing.

| Option | Type | Default |
|---|---|---|
| `name` | str | attr name |
| `hostName` | str | `name` |
| `system` | str | parent key (`x86_64-linux`, `aarch64-darwin`, …) |
| `class` | str | `nixos` for `*-linux`, `darwin` for `*-darwin` |
| `aspect` | raw | `den.aspects.<name>` |
| `users` | attrsOf userType | `{}` |
| `description` | str | `<class>.<hostName>@<system>` |
| `resolved` | raw | resolved aspect from the pipeline |
| `instantiate` | raw | `nixosSystem` / `darwinSystem` / `system-manager` per class |
| `intoAttr` | listOf str | `[ "nixosConfigurations" name ]` / `darwinConfigurations` / `systemConfigs` |
| `collisionPolicy` | null \| `error`\|`den-wins`\|`class-wins` | `null` |
| `home-manager.enable` / `.module` | bool / deferredModule | some user lists `homeManager`; `inputs.home-manager.<class>Modules.home-manager` |
| `hjem.enable` / `.module` | same | same, for `hjem` |
| `nix-maid.enable` / `.module` | same (NixOS only) | same, for `maid` |
| `wsl.enable` / `.module` | bool (default `false`) / deferredModule | `inputs.nixos-wsl.nixosModules.default` |
| `*` | from `den.schema.host` + freeform | |

`instantiate = [ ]`-style skipping: `intoAttr = [ ]` omits placement.

### `den.hosts.<sys>.<name>.users.<user>` — `attrsOf userType`

| Option | Type | Default |
|---|---|---|
| `name` | str | attr name |
| `userName` | str | `name` |
| `classes` | listOf str | `[ "user" ]` — Nix classes this user participates in |
| `aspect` | raw | `den.aspects."<user>@<host>"` **and** `den.aspects.<user>` (both apply) |
| `host` | raw | parent host |
| `resolved`, `collisionPolicy` | | as host |
| `*` | `den.schema.user` + freeform | |

### `den.homes` — `attrsOf homeSystemType`

Key `user@host` binds a home to a host user; a bare key is a standalone home.

| Option | Type | Default |
|---|---|---|
| `name` | str | registry key (`tux@igloo`) |
| `userName` | str | part before `@` |
| `hostName` | nullOr str | part after `@`, `null` when standalone |
| `host` / `user` | raw | bound entities or `null` |
| `system` | str | parent key |
| `class` | str | `homeManager` |
| `aspect` | raw | `den.aspects."<user>@<host>"` + `den.aspects.<user>` |
| `pkgs` | raw | `inputs.nixpkgs.legacyPackages.<system>` |
| `instantiate` | raw | `inputs.home-manager.lib.homeManagerConfiguration` |
| `intoAttr` | listOf str | `[ "homeConfigurations" name ]` |
| `*` | `den.schema.home` + freeform | |

Every entity also gets `id_hash` (safe comparison; `==` is fragile across module boundaries).

Entity module merge order: **entity itself → `den.schema.<kind>` → `den.schema.conf` → the
kind's built-in type**.

### Entity merge order for home-manager

```nix
den.homes.x86_64-linux."tux@igloo" = { };
den.aspects.tux.homeManager.programs.git.enable = true;               # every tux
den.aspects."tux@igloo".homeManager.programs.git.userEmail = "tux@igloo.example";  # this home only
```

### Freeform metadata

```nix
den.hosts.x86_64-linux.laptop = { users.alice = {}; gpu = "nvidia"; };

den.aspects.laptop.includes = [
  ({ host, ... }: lib.optionalAttrs (host ? gpu) { nixos.hardware.nvidia.enable = true; })
];
```

Prefer `den.schema.host` when an attribute must exist on **every** entity of a kind (gives type
checking + docs):

```nix
den.schema.host = { host, lib, ... }: {
  options.hardened = lib.mkEnableOption "Is it secure";
  config.hardened = lib.mkDefault true;
};
den.schema.user = { user, lib, ... }: { config.classes = lib.mkDefault [ "homeManager" ]; };
```

---

## 4. Reference: aspects

An aspect is an attrset bundling modules for one or more Nix classes, plus `includes`,
`provides`, `excludes`, `meta`, `classes`.

```nix
den.aspects.gaming = {
  nixos = { pkgs, ... }: { programs.steam.enable = true; };
  homeManager = { pkgs, ... }: { programs.mangohud.enable = true; };
  includes = [ den.aspects.performance ];
  provides.emulation = { nixos.virtualisation.libvirtd.enable = true; };
};
```

Den **auto-creates** an aspect per entity (`den.aspects.<host>`, `den.aspects.<user>`,
`den.aspects."<user>@<host>"`, `den.aspects.<home>`). Declare `den.aspects.*` manually only for
shared aspects, or to *extend* the auto-created ones (any file may).

### Keys of an aspect

| Key | Type | Meaning |
|---|---|---|
| `<class>` | module / function-module | config merged into entities of that class |
| `includes` | list | providers (aspects, sub-aspects, functions) pulled in |
| `excludes` | list | aspects/policies excluded from this subtree |
| `provides` (alias `_`) | submodule | named sub-aspects → `den.aspects.<name>.<sub>` |
| `policies` | submodule | named policy functions declared by the aspect |
| `meta` | freeform submodule | `handleWith`, `aspect-chain`, `collisionPolicy`, `guard`, `aspects`, plus auto `name`/`loc`/`file`/`self` |
| `classes` | lazyAttrsOf raw | class schemas declared by this aspect, merged into `den.classes` |
| `name`, `description` | str | |
| `__functor` | function | makes the aspect callable; built-in default dispatches on context |
| `__args` | internal | parametric aspect args — not an authoring surface |

`den.lib.parametric` is **deprecated**: every aspect already has a `__functor`.

### Static vs parametric includes

- Plain attrset / module-signature function (`{ ... }:` / `{ config, ... }:`) → **static**,
  emitted once.
- Any function requesting context (`{ host }`, `{ user }`, `{ home }`, `{ host, user }`) →
  **parametric**, deferred and re-resolved per matching scope.
- Function accepting `{ class, aspect-chain }` → static leaf receiving the class being resolved
  and the `meta.aspect-chain` of the current aspect (most recent last).

### Parametric binding rules (3 cases)

At scope `S`, destructuring an entity-kind arg:

1. **In context at `S`** → bound once.
2. **Descendant in the schema DAG** (`user` under `host`) → fan out, emit **class-locally at `S`**.
3. **Neither** (misplaced arg, or any entity kind at root/flake scope) → **silently inert**, no
   warning.

Consequence: a host-scope `{ user, ... }` aspect fans out over users but emits on the *host*
class. It no longer delivers `homeManager` content to users (breaking change). To target
another entity, use `provides`, an explicit policy, or the `host-aspects` battery.

Cross-entity delivery (host configuring a sibling host) is **not** expressible via parametric
args.

### Three kinds of aspect attributes

1. Owned configs — `den.aspects.laptop.nixos.networking.hostName = "laptop";` (attrset or function)
2. Includes — `includes = [ … ];`
3. Provides — named sub-aspects:
   ```nix
   den.aspects.igloo.gpu = { host, ... }: lib.optionalAttrs (host ? gpu) { … };
   den.aspects.igloo.provides.alice.homeManager.programs.vim.enable = true;
   ```
   Cross-entity special keys (permanent API, fire during the tree walk):
   ```nix
   den.aspects.igloo = {
     provides.to-users = { user, ... }: { homeManager.programs.helix.enable = user.name == "alice"; };
     provides.to-hosts = { host, ... }: { nixos.programs.nh.enable = host.name == "igloo"; };
     provides.igloo.nixos.programs.emacs.enable = true;
   };
   ```
   For new work prefer `den.policies` + `policy.include` (more explicit).

### Class modules (two-layer vs flat)

```nix
# Two-layer: context outside, module args inside
den.aspects.a = { host }: { nixos = { config, pkgs, ... }: { networking.hostName = host.name; }; };

# Flat: mixed — Den splits args by shape
den.aspects.a = { nixos = { host, config, pkgs, ... }: { networking.hostName = host.name; }; };

# Full application: every arg is a context arg → called directly
den.aspects.a = { nixos = { host }: { config, ... }: { networking.hostName = host.name; }; };
```

Rules:

- Flat-form class modules **must** include `...` (the module system passes extra args).
- Full application (all args are context args) needs no `...`.
- Aspect-level context wrappers should **omit** `...`.
- Missing **entity** arg ⇒ module is **skipped** with `lib.warn` (no error). Non-entity args are
  left to the module system.
- Den injecting an arg that the module system also supplies (`specialArgs`/`_module.args`) →
  **error by default**.

Mechanism: `builtins.functionArgs` → args found in the pipeline context are pre-applied; the rest
are advertised via `lib.setFunctionArgs`; at call time the wrapper merges both.

### Getting non-entity data into class modules

In preference order:

1. **Close over `inputs` in the defining file.** `{ inputs, ... }: { den.aspects.x.nixos.imports = [ inputs.disko.nixosModules.disko ]; }`
2. **`flake-scope` battery** exposes `lib`, `inputs`, `den` to pipeline functions *and* class
   modules (`inputs'`, `den`).
   ```nix
   den.default.includes = [ den.batteries.flake-scope ];
   den.aspects.tux.homeManager = { inputs, pkgs, ... }: { … };
   ```
3. **home-manager `extraSpecialArgs`** on the host:
   ```nix
   den.aspects.igloo.nixos.home-manager.extraSpecialArgs.site = "example.com";
   den.aspects.tux.homeManager = { site, ... }: { … };
   ```
4. A real `specialArgs` (only if the arg must be visible during `imports` resolution).

Entity data (`host`, `user`, `home`) never needs any of this.

### Collision policy

Resolved from four levels, first non-null wins: aspect `meta.collisionPolicy` → entity
`collisionPolicy` → `den.schema.<kind>.collisionPolicy` → `den.config.classModuleCollisionPolicy`
(global default `"error"`).

Values: `"error"` (throw), `"den-wins"`, `"class-wins"` (warn + win).

### `den.default`

Applied to **all** hosts, users and homes (injected as a schema include). Right place for
`stateVersion` and global policy.

```nix
den.default = {
  nixos.system.stateVersion = "25.11";
  homeManager.home.stateVersion = "25.11";
  includes = [ den.batteries.define-user den.batteries.inputs' ];
};
```

Owned/static configs are deduplicated; **parametric functions in `den.default.includes` are
evaluated at every context stage** — write them as bare functions and rely on dispatch.
`den.lib.perHost`/`perUser`/`perHome` still exist but warn; `den.lib.take.exactly` is deprecated.

### Aspect settings (typed per-host tunables)

Pattern, not a battery. Lets an aspect declare a typed slot and read it as `host.settings.<path>`.

```nix
den.reservedKeys = [ "settings" ];        # 1. reserve the key (not dispatched as class/nested aspect)

den.aspects.kernel = {
  settings.variant = lib.mkOption {        # 2. declare on the STATIC aspect attrset
    type = lib.types.enum [ "lts" "latest" ];
    default = "latest";
  };
  nixos = { host, pkgs, ... }:
    let cfg = host.settings.kernel; in {
      boot.kernelPackages = if cfg.variant == "lts" then pkgs.linuxPackages else pkgs.linuxPackages_latest;
    };
};

den.hosts.x86_64-linux.igloo = {          # 3. set per host
  users.tux = { };
  settings.kernel.variant = "lts";
};
```

Plus a generator module (`_settings-type.nix`, user code) attached to `den.schema.host.imports`
that walks `den.aspects` and emits one typed `settings` submodule per aspect-tree node,
skipping `isStructuralKey k || den.classes ? k || den.quirks ? k`. See
https://den.denful.dev/guides/aspect-settings/ for the full generator source.

Rules: settings paths mirror the aspect tree; only branches with a `settings` block get an
option; `settings` holds **declarations** (use `mkOption { default = … }` or module-shaped
`config`/`imports`), never bare values; reserved keys are **not merged** (last definition wins
silently); `settings` on a fully-functional aspect is invisible to the generator; `settings` are
inputs to one entity — use **quirks** to publish data for collection; priority order is
`default` < `mkDefault` < plain value < `mkForce`.

### Manual resolution (library use)

```nix
aspect = den.lib.aspects.resolve "nixos" (den.aspects.my-aspect { host = den.hosts.x86_64-linux.laptop; });
nixosConfigurations.my-laptop = lib.nixosSystem { modules = [ aspect ]; };
```

`den.hosts.<sys>.<name>.mainModule` gives the fully-resolved module for a host (also the escape
hatch used while migrating from a non-Den flake).

---

## 5. Reference: policies

A policy is a **function from context to a list of effects**. Declaring it in `den.policies` only
*registers* it; it fires when placed in an `includes` list and its argument shape is satisfied.

```nix
den.policies.host-to-peers = { host, ... }:
  let inherit (den.lib.policy) resolve; in
  [ (resolve { myFlag = true; }) ];
```

### Activation

```nix
den.default.includes    = [ den.policies.p ];   # everywhere
den.schema.host.includes = [ den.policies.p ];   # every host
den.aspects.igloo.includes = [ den.policies.p ]; # this aspect subtree
```

`excludes` prevents firing in a subtree; **parent excludes are authoritative over child includes**.
Aspects and policies mix freely in `includes`.

### Effect constructors (`den.lib.policy.*`)

| Effect | Meaning |
|---|---|
| `resolve bindings` | new scope with bindings merged into context |
| `resolve.shared bindings` | shared (non-isolated) fan-out |
| `resolve.to kind bindings` | resolve a specific entity kind |
| `resolve.shared.to kind bindings` | shared fan-out + explicit kind |
| `resolve.withIncludes includes bindings` / `.to.withIncludes` | attach includes to the new scope |
| `include aspect` | inject an aspect into the current resolution (walks the aspect tree) |
| `exclude aspect` | remove an aspect via the constraint registry |
| `deliver spec` | user-facing delivery primitive (below) |
| `route spec` | sugar over `deliver`: `fromClass`→`from`, `intoClass`→`to`, `path`→`at` |
| `provide spec` | sugar over `deliver`: `class`→`to`, `module`→`from.module` |
| `instantiate spec` | request post-pipeline instantiation (entity, or `{ name, class, instantiate, intoAttr }`) |
| `spawn { classes ? null }` | deferred node spawn, resolved post-walk over the parent's full scope tree |
| `pipe` | pipe builder |
| `pipelineOnly value` | tag a value `collisionPolicy = "class-wins"` |
| `mkPolicy name fn` | build `{ __isPolicy = true; name; fn; }` |
| `for entity policy` / `when predicate policy` | conditional wrappers (preserve identity so `excludes` still matches) |

### `policy.resolve` — enrichment vs entity resolution

Bindings whose keys match `den.schema` kinds ⇒ **new child scope**. Non-entity keys ⇒ **enrich**
the current scope (no new scope; deferred aspects needing the bindings are drained).

```nix
policy.resolve { myFlag = true; }                 # enrichment
policy.resolve.to "user" { inherit host user; }   # entity resolution
```

### `policy.deliver`

```nix
policy.deliver {
  from = "myClass";                  # source class name (class source)
  to = "nixos";                      # target class
  at = [ "services" "myService" ];   # attrpath; [] = merge at class root
  mode = "merge";                    # "merge" (default) | "nest" | "verbatim"
  guard = args: args.options ? myService;      # optional
  adaptArgs = args: { osConfig = args.config; }; # optional
}
```

- `merge` — union into the target class bucket (use `at = []`).
- `nest` — evaluate and place at `at`.
- `verbatim` — place collected module wrappers **by reference** (for targets whose `merge`
  re-instantiates, e.g. microvm guest config). There is no `reinstantiate` flag; use `mode`.
- `guard` failing ⇒ contributes nothing. `adaptArgs` adapts module args (with non-empty `at`,
  source modules eval in a submodule whose `specialArgs` = `adaptArgs` applied to target args).
- `policy.deliver` deliberately has **no** `appendToParent`.
- Passing both `path` and `intoPath` to `policy.route` is an error.

### `policy.include` vs `policy.provide`

| | `include` | `provide` |
|---|---|---|
| path | walks the aspect tree | bypasses the tree |
| dedup | include dedup | deduped by policy/class/path |
| use for | aspects participating in full resolution (constraints, nested includes, parametric dispatch) | delivering raw modules straight to a class |

### Built-in policies

Entity traversal (`policies/core.nix`):

| Policy | From → To | Behaviour |
|---|---|---|
| `host-to-users` | `host` → `user` | one shared `{ host, user }` scope per user. A freeform key on the host aspect matching a user name is also included — but it currently reaches **every** user; prefer `provides.<user>` |
| `os-to-host` | `os` class | route `os` content to the host's own OS class, in every scope binding a host |
| `user-to-host` | `user` class | route to `users.users.<userName>`, injecting `osConfig` |
| `host-to-hm-users` / `hm-user-detect` | `homeManager` | import HM OS module; forward each HM user into `home-manager.users.<name>` |
| `host-to-hjem-users` / `hjem-user-detect` | `hjem` | → `hjem.users.<name>` |
| `host-to-maid-users` / `maid-user-detect` | `maid` (NixOS only) | → `users.users.<name>.maid` |
| `host-to-wsl-host` / `wsl-to-host` | `wsl` | resolve `wsl-host` when `host.wsl.enable` on a NixOS host; route to host's `wsl.*` |

Flake output traversal (`policies/flake.nix`):

| Policy | From → To |
|---|---|
| `flake-to-systems` | `flake` → `flake-system` (one per `den.systems` entry) |
| `system-to-os-outputs` | `flake-system` → `host` (+ instantiate) |
| `system-to-hm-outputs` | `flake-system` → `home` (+ instantiate) |
| `packages-to-flake`, `apps-to-flake`, `checks-to-flake`, `devShells-to-flake`, `legacyPackages-to-flake` | route classes to flake outputs |

Flake-parts (opt-in via `den.schema`, only registered when `inputs.flake-parts` exists):
`system-to-flake-parts` (`flake-system` → `flake-parts`, one `{ flake-parts }` per system),
`packages-to-flake-parts` (`packages` class → perSystem `packages`, `collectSubtree = true`).

The `flake-scope` battery carries its own `den-flake-scope` policy for pipeline-arg enrichment.

### Conditional policies

```nix
den.schema.host.includes = [
  (den.lib.policy.when ({ host, ... }: host.wsl.enable) den.policies.wsl-support)
  (den.lib.policy.for den.hosts.x86_64-linux.igloo den.policies.igloo-only)
];
```

`den.lib.policy.when` over an **inline aspect** is different: it compiles to a conditional aspect
(`meta.guard`) whose guard is evaluated against the in-flight tree using a structural,
exclude-aware `hasAspect` — this is what makes `host.hasAspect den.aspects.git` safe. Failed
guards are parked and re-evaluated after siblings resolve (order-independent); unrecoverable
guards leave a visible tombstone.

### Inspecting policies

```nix
den.lib.policyInspect.inspect {
  kind = "host";
  context = { host = den.hosts.x86_64-linux.laptop; };
}
```

Returns per-policy targets, routing type, source/destination entity kinds. Calls resolve
functions directly — no full pipeline run.

---

## 6. Reference: quirks & pipes

A **quirk** is named structured data emitted by aspects; a **pipe** is a policy effect that
routes / filters / transforms / aggregates it. Use quirks to decouple producers from consumers.

### 1. Declare

```nix
den.quirks.firewall = { description = "Firewall port declarations"; };
```

Quirk names must not collide with `den.classes` names (asserted at eval).

### 2. Produce

```nix
den.aspects.nginx   = { nixos.services.nginx.enable = true;       firewall = { ports = [ 80 443 ]; }; };
den.aspects.postgres = { nixos.services.postgresql.enable = true; firewall = { ports = [ 5432 ]; }; };
```

Any Nix value is allowed; **list values are auto-flattened**.

### 3. Consume

```nix
den.aspects.networking = {
  nixos = { firewall, lib, ... }: {
    networking.firewall.allowedTCPPorts = lib.concatMap (f: f.ports or []) firewall;
  };
};
```

The quirk arg is a **list of all values in the consuming scope**, whatever the class; `[]` when
no producers. Consumers are deferred until pipe assembly ⇒ **include order does not matter**.
No pipe policy is needed for same-scope aggregation.

### Scope model (default: scope-local)

| Emitted on | Read by | Sees |
|---|---|---|
| `igloo` | `igloo.nixos` | igloo's values |
| `tux` | `tux.homeManager` / `tux.nixos` | tux's values |
| `tux` | `igloo.nixos` | nothing (user data stays in user scope) |
| `alice` | `tux.homeManager` | nothing (siblings isolated) |
| `igloo` | `tux.homeManager` | nothing unless a host-scope pipe policy binds the pipe — **and only if the user emits nothing of its own** |

### Pipe stages (`den.lib.policy.pipe`)

```nix
den.policies.my-pipe = { host, ... }:
  let inherit (den.lib.policy) pipe; in
  [ (pipe.from "firewall" [ … ]) ];        # pipeName = string or den.quirks.firewall
```

Transform stages (chain left → right):

| Stage | Effect |
|---|---|
| `pipe.filter pred` | keep entries where `pred` is `true` |
| `pipe.transform fn` | `[a,b]` → `[fn a, fn b]` |
| `pipe.fold fn init` | `[10,20,30]` → `[60]` (consumer gets a 1-element list) |
| `pipe.append v` | append a value |
| `pipe.for fn` | **replace the whole list**; `fn` must return a list. At most one per pipe per scope |

Routing stages (put these *after* transforms):

| Stage | Effect |
|---|---|
| `pipe.expose` | push data child → parent; merges with parent's local data |
| `pipe.collect pred` | harvest from **sibling** scopes (non-terminal) |
| `pipe.collectAll pred` | harvest from **every** matching scope (fleet-wide) |
| `pipe.broadcast pred` | push broadcaster's value to **every** other matching scope (fleet-wide) |
| `pipe.to aspects` | route data to specific aspects by identity |
| `pipe.as "other-quirk"` | rename output → derived quirk (must differ from source) |
| `pipe.withProvenance` | wrap entries as `{ value, source }` |

```nix
pipe.from "http-backends" [
  (pipe.collect ({ host, ... }: true))     # sibling hosts
  (pipe.filter (b: b.port != 8080))
  (pipe.transform (b: "${b.addr}:${toString b.port}"))
  (pipe.as "monitoring-targets")
]
```

**Entity-kind filtering is automatic** for `collect`/`collectAll`/`broadcast`: a scope is
considered only when its own entity kind is among the predicate's required args. `({ host, ... }: …)`
matches host scopes only; `(_: true)` matches no entity scope.

`pipe.broadcast` gotchas: source values are the broadcaster's **raw emits** (data exposed *into*
it is not folded in); receivers get values **after** their own transforms, appended to their pool.

`pipe.withProvenance`: consumers receive `{ value; source }`; `pipe.filter`/`pipe.transform` then
see **unresolved** config thunks — don't mix with config-thunk producers.

### Config-dependent thunks

```nix
den.aspects.my-service.firewall = { config, ... }: { ports = [ config.services.my-service.port ]; };
```

- `config` is always the **producer's** config (class + scope where it was produced).
- Nested classes get the owning host's config under the class's `parentArg` (`osConfig`).
- Local thunks resolve lazily inside `evalModules`; **cross-host** thunks (`collect`/`broadcast`)
  resolve **eagerly** against the source's instantiated config. Cross-host config-dependent
  dependencies must form a DAG — a↔B reads ⇒ infinite recursion.
- Context-parametric quirk values (asking only for context args) are **called at the producing
  scope**, so consumers get a plain record.

### Fleet example (end to end)

```nix
den.quirks.http-backends = { description = "HTTP backend endpoints"; };
den.aspects.igloo   = { http-backends = { addr = "10.0.0.1"; port = 8080; }; };
den.aspects.iceberg = { http-backends = { addr = "10.0.0.2"; port = 80; }; };

den.policies.fleet-backends = { host, ... }:
  let inherit (den.lib.policy) pipe; in
  [ (pipe.from "http-backends" [ (pipe.collect ({ host, ... }: true)) ]) ];
den.schema.host.includes = [ den.policies.fleet-backends ];

den.aspects.haproxy = {
  nixos = { http-backends, lib, ... }: {
    services.haproxy.config = lib.concatMapStringsSep "\n"
      (b: "server ${b.addr} ${b.addr}:${toString b.port}") http-backends;
  };
};
den.aspects.igloo.includes = [ den.aspects.haproxy ];
```

Custom fleet hierarchy (the `fleet` entity kind is pre-registered):

```nix
den.policies.to-fleet = _: [ (den.lib.policy.resolve.to "fleet" { fleet = { name = "production"; }; }) ];
den.policies.fleet-to-hosts = { fleet, ... }: /* resolve.to "host" + instantiate for each host */;
den.schema.flake.includes = [ den.policies.to-fleet ];
den.schema.fleet.includes = [ den.policies.fleet-to-hosts ];
```

### Choose the mechanism

| What | When |
|---|---|
| **Quirks + pipes** | structured data aggregation within/across scopes |
| **Policies** | entity topology (fan-out, routing, enrichment) |
| **`provides`** | cross-entity aspect delivery (host ↔ user) |
| **Class modules** | NixOS / Darwin / HM configuration |

---

## 7. Reference: batteries

Aliases: `den.batteries` = `den.provides` = `den._`.

### Opt-in (place in an `includes` list)

| Battery | Effect |
|---|---|
| `den.batteries.define-user` | creates `users.users.<name>` (+ home dir, `isNormalUser` on NixOS, HM `home.username`/`homeDirectory`) |
| `den.batteries.hostname` | sets `networking.hostName` from `host.hostName` (nixos/darwin/wsl) |
| `den.batteries.primary-user` | NixOS: `wheel` + `networkmanager`; Darwin: `system.primaryUser`; WSL: `defaultUser` |
| `(den.batteries.user-shell "zsh")` | enables `programs.<shell>`, sets login shell at OS + HM |
| `(den.batteries.unfree [ "vscode" ])` | `allowUnfreePredicate` in nixos/darwin/homeManager |
| `(den.batteries.insecure [ "openssl-1.1.1w" ])` | `permittedInsecurePackages` |
| `den.batteries.host-aspects` | projects user-relevant classes (e.g. `homeManager`) from a host aspect tree onto opted-in users |
| `den.batteries.tty-autologin "alice"` | systemd getty autologin (NixOS) |
| `den.batteries.vm-autologin "alice"` | VM autologin (NixOS VMs) |
| `den.batteries.forward { … }` | generic forwarding primitive / custom class factory |
| `den.batteries.import-tree` | auto-import `.nix` files; class from dir name (`_<class>/`) |
| `den.batteries.flake-scope` | exposes `lib`, `inputs`, `den` to pipeline functions *and* class modules |
| `den.batteries.inputs'` | `inputs'` as a top-level module arg (per-system inputs) |
| `den.batteries.self'` | `self'` as a top-level module arg |
| `den.batteries.mutual-provider` | **inert compatibility shim, no effects** |

```nix
den.default.includes = [ den.batteries.define-user den.batteries.hostname den.batteries.flake-scope ];
den.aspects.alice.includes = [
  den.batteries.primary-user
  (den.batteries.user-shell "zsh")
  (den.batteries.unfree [ "nvidia-x11" "steam" ])
];
```

### Auto-activated (define classes / integration layers — nothing to include)

| Class / layer | Requires | Behaviour |
|---|---|---|
| `os` | — | `os` content lands in the host's own OS class (fires in every scope binding a host) |
| `user` | — | forwards to `users.users.<userName>`; default entry of `users.<name>.classes` |
| `wsl` | `inputs.nixos-wsl` or `host.wsl.module` | activates on `nixos` hosts with `wsl.enable = true`; creates `wsl-host` kind; routes to host `wsl.*` |
| `homeManager` | `inputs.home-manager` (or `host.home-manager.module`) | NixOS + Darwin; imports HM OS module; forwards into `home-manager.users.<name>`; `osConfig` = host config |
| `hjem` | `inputs.hjem` | forwards into `hjem.users.<name>` |
| `maid` | `inputs.nix-maid`, NixOS only | forwards into `users.users.<name>.maid` |
| `flake-parts` | `inputs.flake-parts` | per-system `perSystem` modules |

**Activation rule**: writing `homeManager`/`hjem`/`maid` on an aspect is *not enough* — at least
one user must list the class in `users.<name>.classes`.

```nix
den.hosts.x86_64-linux.igloo.users.alice.classes = [ "homeManager" "hjem" ];
den.schema.user.classes = lib.mkDefault [ "homeManager" ];      # default for all users
den.aspects.alice.homeManager.programs.git.enable = true;
den.aspects.alice.hjem = { pkgs, ... }: { packages = [ pkgs.ripgrep ]; };
```

Standalone homes (host need not be Den-managed):

```nix
den.homes.x86_64-linux."tux@igloo" = { };
den.homes.x86_64-linux.tux = { };        # fully standalone
```

### `forward` spec

```nix
den.batteries.forward {
  each = lib.attrValues host.users;          # items to forward
  fromClass = item: "myClass";               # source class
  intoClass = item: host.class;              # target class
  intoPath  = item: [ "users" "users" item.userName ];
  fromAspect = item: item.aspect;            # defaults to item.resolved
  guard = args: bool;                        # optional
  adaptArgs = args: attrs;                   # optional
  adapterModule = { … };                     # optional, submodule type override
}
```

Guard forms: `lib.optionalAttrs` when testing whether an **option is defined**; `lib.mkIf` when
testing a **config value**.

### Custom classes without `forward`

```nix
den.classes.files = { };
den.policies.files-to-flake-parts = _: [
  (den.lib.policy.route { fromClass = "files"; intoClass = "flake-parts"; path = [ "files" ]; })
];
den.schema.flake-parts.includes = [ den.policies.files-to-flake-parts ];
```

`den.classes.<name>` fields: `description`, `forwardTo = { class; path?; }`,
`parentPath = name: path` (nested classes), `parentArg` (module arg reaching the enclosing
owner, e.g. `osConfig`). Den's own: `den.classes.homeManager.parentPath = u: [ "home-manager" "users" u ]`,
`den.classes.homeManager.parentArg = "osConfig"`.

### `import-tree`

```nix
den.schema.host.includes = [ (den.batteries.import-tree.provides.host ./hosts) ];
den.schema.user.includes = [ (den.batteries.import-tree.provides.user ./users) ];
den.aspects.laptop.includes = [ (den.batteries.import-tree ./disko) ];
```

### flake-parts integration

```nix
den.default.includes = [ den.batteries.inputs' den.batteries.self' ];
# perSystem
perSystem = { pkgs, ... }: { packages = den.lib.nh.denPackages { fromFlake = true; } pkgs; };
```

---

## 8. Reference: outputs

```
den.hosts + den.homes  →  resolution  →  flake.*Configurations
```

Per host:

```nix
host.instantiate {
  modules = [ host.mainModule { nixpkgs.hostPlatform = lib.mkDefault host.system; } ];
}
```

Per home:

```nix
home.instantiate { pkgs = home.pkgs; modules = [ home.mainModule ]; }
```

| Option | Type | Default |
|---|---|---|
| `den.systems` | listOf str | union of host/home system keys; falls back to `lib.systems.flakeExposed` |
| `flake.nixosConfigurations.<name>` | | hosts with `class = "nixos"` |
| `flake.darwinConfigurations.<name>` | | hosts with `class = "darwin"` |
| `flake.homeConfigurations.<name>` | | homes |
| `flake.systemConfigs.<name>` | | `class = "systemManager"` |
| `flake.denful.<ns>` | raw | exported namespaces |

Contributing `packages` / `checks` / `devShells` / `legacyPackages` / `apps` from aspects
(needed without flake-parts, or with multiple definitions to merge):

```nix
# modules/outputs.nix
{ inputs, ... }: { imports = [ inputs.den.flakeOutputs.packages ]; }

den.schema.flake-system.includes = [ den.aspects.foo ];

den.aspects.foo.packages = { pkgs, ... }: { inherit (pkgs) hello; };
```

With flake-parts, use its own `perSystem` and `den.batteries.inputs'` / `self'`.

### `den.lib.nh` wrappers

`den.lib.nh.denPackages args pkgs`, `denShell`, `denApps`, `hostApps`, `homeApps`.
`args`: `fromFlake` (default `true`), `fromPath` (`"."`), `outPrefix` (`[]`),
`defaultAction` (`"build"`), `defaultArgs` (`[]`).

---

## 9. Reference: namespaces, custom classes, extensions

### Namespaces — shareable aspect libraries

```nix
# modules/namespace.nix
{ inputs, den, ... }: {
  imports = [ (inputs.den.namespace "my" false) ];      # local only
  imports = [ (inputs.den.namespace "eg" true) ];       # create + export to flake.denful.eg
  imports = [ (inputs.den.namespace "shared" [ inputs.team-config true ]) ];  # import + re-export
}

# modules/aspects/vim.nix
{ eg.vim = { homeManager.programs.vim.enable = true; }; }

# modules/aspects/desktop.nix
{ eg, ... }: { eg.desktop = { includes = [ eg.vim ]; nixos.services.xserver.enable = true; }; }

# modules/hosts.nix
{ eg, ... }: { den.aspects.laptop.includes = [ eg.desktop eg.vim ]; }
```

Second arg = boolean (export?) or list of upstream sources whose `flake.denful.<name>` merges in;
include `true` in the list to also export. With `den.lib.__findFile` installed
(`_module.args.__findFile = den.lib.__findFile;`) you can reference `<eg/desktop>`.

### Custom classes

See §7 (`forward` / `route`). A class forwards its content into a target attrpath on another
class. Use it for nested namespaces and integration layers (home-manager, hjem, maid, WSL,
terranix, microvm guests, …).

### Extending the pipeline with a new entity kind

```nix
den.policies.my-kind-from-host = { host, ... }:
  [ (den.lib.policy.resolve.to "my-kind" { inherit host; }) ];
den.policies.my-kind-to-outputs = { my-kind, ... }:
  [ (den.lib.policy.instantiate { name = …; class = "…"; instantiate = { modules, ... }: modules; intoAttr = [ … ]; }) ];
den.schema.host.includes = [ den.policies.my-kind-from-host ];
den.schema.my-kind.includes = [ den.policies.my-kind-to-outputs ];
```

See https://den.denful.dev/tutorials/microvm/ for the worked example.

### `den.lib` surface

Public-ish entries worth knowing:

- `den.lib.aspects.resolve class aspect` / `resolveImports` / `resolveWithPaths` /
  `resolveWithState` — **internal** resolution helpers (used by `den.lib.capture`).
- `den.lib.aspects.fx.constraints` — `exclude`, `substitute`, `filterBy` handler records for
  `meta.handleWith`.
- `den.lib.aspects.hasAspectIn`, `collectPathSet`, `mkEntityHasAspect`, `mkProjectedHasAspect`.
- `den.lib.resolveEntity kind ctx` — build an aspect-like record for an entity outside the pipeline.
- `den.lib.policy.{resolve,include,exclude,route,provide,instantiate,spawn,deliver,pipe,pipelineOnly,mkPolicy,for,when}`.
- `den.lib.policyInspect.inspect`.
- `den.lib.home-env.{makeHomeEnv,mkDetectHost,mkIntoClassUsers}` — build a home-env battery.
- `den.lib.capture` (+ `den-diagram`) — capture resolution traces for diagrams.
- `den.lib.__findFile` — angle-bracket resolver.
- `den.lib.nh.*` — wrappers.
- `den.lib.strict` — applied through `den.schema.aspect`.
- Legacy/deprecated: `den.lib.parametric`, `den.lib.take.exactly`, `den.lib.perHost` /
  `perUser` / `perHome` (warn), `den.lib` old parametric dispatch, `den.ctx`.

---

## 10. Under the hood: effects (for contributors)

Den's pipeline is built on `nix-effects` — algebraic effects + handlers, trampoline-based
evaluation. API via `den.lib.fx`.

```nix
fx.handle { handlers = {}; } (fx.pure 22)          # => { state = null; value = 22; }
fx.send "hostName" null                             # an Effect Request; crashes if unhandled

fx.handle {
  handlers.hostName = { param, state }: { resume = "igloo"; inherit state; };
  state = {};
} (fx.send "hostName" null)

fx.bind.fn {} myFn   # turns any pure fn into a computation: one request per arg
```

A handler receives `{ param, state }` and returns `{ resume, state }`. Mocking handlers gives
cheap unit tests of derivation-producing functions.

How Den uses it: each aspect arg (`host`, `user`) becomes an effect request; the pipeline is the
handler supplying values per machine/person. Aspects additionally *contribute* class content via
requests, enabling centralized dedup, feature detection, aspect replacement and inter-aspect
messaging.

Lineage: `denful/nix-effects` → `denful/nfx` → `denful/fx-rs` → `denful/fx.go`.
Den is moving onto **gen** (https://gen.wtf/) for typed entities; see
https://den.denful.dev/future/.

---

## 11. Pipeline walk order (walk-then-instantiate)

1. **Walk** the scope tree from `flake`, collecting aspects, pipe data, routes and instantiate
   requests into scope-partitioned state. Includes are deduplicated by `"${scope}/${identityKey}"`.
2. **Pipe assembly** (`assemblePipes`, post-walk): expose pass → broadcast pass → per-scope
   assembly (extract raw entries, merge exposed child data, mark local config thunks, apply
   untargeted pipe effects, route inbound `pipe.as`, build `pipe.to` targets) → inject into scope
   contexts.
3. **Per-host extraction** (`applyInstantiates`): filter shared state to each host's subtree
   (host scope + descendants + ancestors such as `flake-system`, whose routes/provides must stay
   visible), then re-run class wrapping, provides and routes with the host as root scope.
4. **Instantiation** via each entity's `instantiate`.

⇒ `pipe.collect` always sees all hosts' data; no walk-order sensitivity.

Built-in policy graph:

```
flake ──flake-to-systems──> flake-system
flake-system ──system-to-os-outputs──> host
flake-system ──system-to-hm-outputs──> home
host ──host-to-users──> user
host ──host-to-hm-users──> home-manager users
```

---

## 12. Gotchas checklist

**Class modules / dispatch**
- Flat-form class modules need `...`; aspect-level context wrappers should omit it.
- Full application (all args are context args) needs no `...`.
- Missing **entity** arg in a class module ⇒ skipped + `lib.warn` (not an error).
- A parametric aspect whose entity kind is unreachable at that scope is a **silent no-op**.
- Aspect-arg collisions with `specialArgs`/`_module.args` **error** by default; opt into
  `den-wins` / `class-wins`.
- Class modules naming a **descendant** entity kind are promoted to parametric and fan out
  class-locally at the including scope.

**Entities**
- Darwin hosts have `class = "darwin"`, not `"nixos"`. `host.class` is the OS class, not the
  context type.
- Home-env classes (`homeManager`, `hjem`, `maid`) need the class in `users.<name>.classes`;
  writing the aspect key alone is inert.
- Files under `modules/` starting with `_` are skipped by `import-tree`.
- `den.systems` (not hosts directly) drives the flake→system fan-out.
- `den.default` owned configs are deduped, but parametric functions in `den.default.includes` run
  at every context stage — write bare functions.

**Pipes / quirks**
- Quirk names must not collide with `den.classes` names.
- A quirk **function** value is *called* unless it asks for unbound args (`config`, `pkgs`).
  To deliver a function itself (an overlay), wrap it: `_: [ overlay ]`.
- `pipe.for`'s function must return a **list**; max one `pipe.for` per pipe per scope.
- `pipe.as` must target a different quirk; self-targeting errors.
- `pipe.broadcast`: receiver transforms don't apply; the broadcaster doesn't fold in exposed data.
- `pipe.withProvenance` makes `filter`/`transform` see unresolved thunks.
- Host → user quirk flow happens only if the user emits nothing itself on that pipe.
- Cross-host config-dependent thunks must form a DAG.

**Aspects**
- `meta` is freeform: a stale `meta.provider` is silently absorbed. `meta.aspect-chain`:
  `null` ≠ `[]` (`null` = unset, `[]` = root).
- `excludes` are authoritative — a parent's exclude cannot be overridden by a child's include.
- Host-scope `{ user, ... }` aspects no longer deliver `homeManager` content to users; route via
  `provides.to-users`, a policy, or the `host-aspects` battery.
- Reserved keys (`settings`) are **not merged** across modules — last definition wins silently.
- `settings` must be declared on the static aspect attrset, and holds declarations, not values.

---

## 13. Debugging & tooling

```nix
# expose den temporarily, then remove
{ den, ... }: { flake.den = den; }
```

```console
nix repl                # then :lf .
just repl               # loads denTest + den.lib (does NOT load your project definitions)
```

- **Policy inspection**: `den.lib.policyInspect.inspect { kind = "host"; context = { host = …; }; }`
- **Trace context**: `den.aspects.laptop.includes = [ ({ host, ... }@ctx: builtins.trace ctx { … }) ];`
  (`builtins.break ctx` to drop into a debugger)
- **Manual resolve**:
  ```nix
  module = den.lib.aspects.resolve "nixos" den.aspects.laptop
  module = den.hosts.x86_64-linux.igloo.mainModule          # context-dependent
  cfg = (lib.nixosSystem { modules = [ module ]; }).config
  ```
- **Diagrams**:
  ```nix
  diagram = inputs.den-diagram.lib;
  captured = den.lib.capture.captureWithPathsWith {
    classes = [ "nixos" "homeManager" ];
    root = den.lib.resolveEntity "host" { inherit host; };
    ctx = { inherit host; };
  };
  diagram.toMermaid (diagram.context { entries = captured.entries; name = host.name; })
  ```
- Common symptoms: duplicate list entries (parametric `den.default.includes`), missing attribute
  (context lacks the expected param — trace keys), wrong class (Darwin), module not found (`_`
  prefix or outside `modules/`).

Templates to start from: `tutorials/minimal`, `tutorials/default`, `tutorials/noflake`,
`tutorials/nvf-standalone`, `tutorials/example`, `tutorials/flake-parts-modules`,
`tutorials/ci`. See https://den.denful.dev/tutorials/overview/.

---

## 14. Doc index (URLs)

**Start**: `/overview/` · `/motivation/` · `/guides/from-zero-to-den/` ·
`/guides/from-flake-to-den/` · `/guides/migrate/` · `/explanation/coming-from/` · `/future/`

**Understand**: `/explanation/core-principles/` · `/explanation/entities/` ·
`/explanation/aspects/` · `/explanation/class-modules/` · `/explanation/parametric/` ·
`/explanation/structural-introspection/` · `/explanation/policies/` ·
`/explanation/policy-activation/` · `/explanation/quirks-and-pipes/` · `/explanation/fleet/` ·
`/explanation/context-pipeline/` · `/explanation/scope-partitioning/` ·
`/explanation/effects/` · `/explanation/diagrams/` · `/explanation/library-vs-framework/` ·
`/explanation/where-config-lands/` · `/explanation/choosing-a-mechanism/`

**Build**: `/guides/declare-hosts/` · `/guides/configure-aspects/` · `/guides/home-manager/` ·
`/guides/standalone-home-manager/` · `/guides/mutual/` · `/guides/quirks/` ·
`/guides/quirks-cross-scope/` · `/guides/quirk-recipes/` · `/guides/aspect-settings/` ·
`/guides/nixpkgs/` · `/guides/flake-outputs/` · `/guides/batteries/` · `/reference/batteries/`

**Extend**: `/guides/custom-classes/` · `/guides/custom-class-examples/` · `/guides/namespaces/` ·
`/guides/angle-brackets/`

**Troubleshoot**: `/guides/debug/` · `/tutorials/bogus/`

**Examples**: `/tutorials/fleet-demo/` · `/tutorials/microvm/` · `/tutorials/terranix-demo/` ·
`/tutorials/case-study-kubernetes/` · `/tutorials/case-study-acl-environments/` ·
`/tutorials/case-study-disks-impermanence/` · `/tutorials/case-study-diagrams/` ·
`/tutorials/overview/`

**Reference**: `/reference/glossary/` · `/reference/schema/` · `/reference/aspects/` ·
`/reference/policies/` · `/reference/quirks/` · `/reference/lib/` · `/reference/diag/` ·
`/reference/output/` · legacy: `/reference/lib-deprecated/`, `/explanation/context-system/`,
`/guides/migrate-ctx/`

**Project**: `/releases/` (bleeding-edge) · `/contributing/` · `/maintainers/` · `/community/`

**Ecosystem**: https://denful.dev (sponsor) · `import-tree`, `flake-aspects`, `flake-file`,
`with-inputs`, `denful`, `dendrix` · `gen`, `gen-schema`, `gen-merge`, `gen-scope`, `gen-graph` ·
DeepWiki: https://deepwiki.com/denful/den · Matrix `#den-lib:matrix.org`