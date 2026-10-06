{lib, ...}: {
  den.schema.host = {host, ...}: {
    options = {
      outputs = lib.mkOption {
        default = {};
        description = "Per-connector display properties, rendered as niri `output` blocks.";
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              width = lib.mkOption {
                type = lib.types.int;
                default = 1920;
                description = "Output width in pixels.";
                example = 2560;
              };
              height = lib.mkOption {
                type = lib.types.int;
                default = 1080;
                description = "Output height in pixels.";
                example = 1440;
              };
              refreshRate = lib.mkOption {
                type = lib.types.nullOr lib.types.number;
                default = null;
                description = ''
                  Refresh rate in Hz. Omitting this will let the compositor pick the highest advertised rate.
                '';
                example = 144;
              };
              transform = lib.mkOption {
                type = lib.types.enum ["normal" "90" "180" "270" "flipped" "flipped-90" "flipped-180" "flipped-270"];
                default = "normal";
                description = "Output transform (rotation/flip).";
              };
              position = lib.mkOption {
                type = lib.types.nullOr (
                  lib.types.submodule {
                    options = {
                      x = lib.mkOption {type = lib.types.int;};
                      y = lib.mkOption {type = lib.types.int;};
                    };
                  }
                );
                default = null;
                description = "Position in the global coordinate space. null = niri default placement.";
                example = {
                  x = 1920;
                  y = 0;
                };
              };
            };
          }
        );
      };
    };
  };

  den.default.nixos = {host, ...}: {
    assertions = [
      {
        assertion = host.outputs != {};
        message = "display-properties: host '${host.name}' defines no outputs. Set den.hosts.<system>.${host.name}.outputs.<connector> = { width = …; height = …; };";
      }
    ];
  };
}
