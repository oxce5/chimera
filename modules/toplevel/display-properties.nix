{
  inputs,
  lib,
  ...
}: let
  inherit (lib) mkOption types;

  displayType = types.submodule (
    {
      name,
      config,
      ...
    }: {
      options = {
        name = mkOption {
          default = name;
          readOnly = true;
        };
        primary = mkOption {
          type = types.bool;
          default = false;
        };
        refresh = mkOption {
          type = types.nullOr types.float;
          default = null;
          description = "Hz to pin. null lets the compositor pick the highest advertised rate for this mode.";
        };
        width = mkOption {
          type = types.int;
          default = 1920;
        };
        height = mkOption {
          type = types.int;
          default = 1080;
        };
        x = mkOption {
          type = types.int;
          default = 0;
        };
        y = mkOption {
          type = types.int;
          default = 0;
        };
        scaling = mkOption {
          type = types.float;
          default = 1.0;
        };
        roundScaling = mkOption {
          type = types.int;
          default = builtins.ceil config.scaling;
        };
        vrr = mkOption {
          type = types.bool;
          default = false;
        };
        transform = mkOption {
          type = types.enum ["normal" "90" "180" "270" "flipped" "flipped-90" "flipped-180" "flipped-270"];
          default = "normal";
          description = "Vertical monitors typically want \"90\" or \"270\".";
        };
        wallpaper = mkOption {
          type = types.nullOr types.path;
          default = null;
          apply = v:
            if v == null
            then null
            else builtins.path {path = inputs.self + v;};
        };
      };
    }
  );
in {
  den.schema.host = {config, ...}: let
    displays = config.displays;
    displayList = builtins.attrValues displays;
    primaries = lib.filterAttrs (_: d: d.primary) displays;
    primaryList = builtins.attrValues primaries;
    primaryNames = lib.concatStringsSep ", " (lib.mapAttrsToList (n: _: n) primaries);
  in {
    options.displays = mkOption {
      type = types.lazyAttrsOf displayType;
      default = {};
    };
    options.primaryDisplay = mkOption {
      type = types.nullOr (types.lazyAttrsOf types.raw);
      readOnly = true;
      description = "Single display when exactly one is defined, or the one flagged `primary`. Throws if several are primary.";
      default =
        if builtins.length displayList == 1
        then builtins.head displayList
        else if builtins.length primaryList == 0
        then null
        else if builtins.length primaryList > 1
        then builtins.throw "Multiple displays marked as primary: ${primaryNames}"
        else builtins.head primaryList;
    };
  };

  den.default.nixos = {host, ...}: {
    assertions = [
      {
        assertion = host.displays != {};
        message = "display-properties: host '${host.name}' defines no displays. Set den.hosts.<system>.${host.name}.displays.<connector> = { width = …; height = …; };";
      }
    ];
  };
}
