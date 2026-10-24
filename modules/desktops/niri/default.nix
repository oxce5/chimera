{
  chimera,
  inputs,
  ...
}: {
  chimera.wayland.niri = {
    includes = [chimera.wayland.base];

    nixos = {
      config,
      pkgs,
      ...
    }: {
      imports = [inputs.niri-nix.nixosModules.default];
      nixpkgs.overlays = [inputs.niri-nix.overlays.niri-nix];
      programs.niri = {
        enable = true;
        package = pkgs.niri-unstable;
        useNautilus = false;
      };
    };
    homeManager = {
      config,
      lib,
      pkgs,
      host,
      ...
    }: let
      mkOutput = d:
        {
          mode = {
            # niri matches the refresh exactly, to three decimals.
            _args = [
              "${toString d.width}x${toString d.height}${lib.optionalString (d.refresh != null) "@${toString d.refresh}"}"
            ];
            # custom mode: refresh is required, niri computes the timings
            _props = lib.optionalAttrs d.custom {
              custom = true;
            };
          };
          position._props = {
            x = d.x;
            y = d.y;
          };
          scale = d.scaling;
          transform = d.transform;
        }
        // lib.optionalAttrs d.vrr {
          variable-refresh-rate._props.on-demand = true;
        }
        // lib.optionalAttrs d.primary {
          focus-at-startup = [];
        };

      outputs = lib.mapAttrs' (name: d: lib.nameValuePair ''output "${name}"'' (mkOutput d)) host.displays;
    in {
      home.packages = with pkgs; [
        # Required for Xwayland applications (burpsuite, etc.) under niri.
        xwayland-satellite
        kitty
      ];
      services = {
        cliphist.enable = true;
        awww.enable = true;
      };
      # Apply each display's wallpaper as soon as the daemon is up; the awww
      # client retries the socket and ping-polls until outputs are configured,
      # so ExecStartPost wins the startup race without a retry script.
      systemd.user.services.awww = lib.mkIf config.services.awww.enable {
        Service.ExecStartPost = lib.mapAttrsToList (
          name: d: "${lib.getExe pkgs.awww} img -o ${name} ${d.wallpaper} -t none"
        ) (lib.filterAttrs (_: d: d.wallpaper != null) host.displays);
      };
      wayland.windowManager.niri = {
        enable = true;
        package = pkgs.niri-unstable;

        settings =
          {
            input = {
              keyboard = {
                xkb = {
                  layout = "";
                  model = "";
                  rules = "";
                  variant = "";
                };
                repeat-delay = 600;
                repeat-rate = 25;
                track-layout = "global";
              };
              touchpad = {
                tap = [];
                natural-scroll = [];
              };
              mouse = {
                accel-speed = -0.600000;
              };
              focus-follows-mouse = [];
            };

            screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
            prefer-no-csd = [];

            overview = {
              workspace-shadow.off = [];
            };

            layout = {
              gaps = 16;
              struts = {
                left = 0;
                right = 0;
                top = 0;
                bottom = 0;
              };
              focus-ring.off = [];
              border.off = [];
              default-column-width = [];
              center-focused-column = "never";
            };

            cursor = {
              xcursor-theme = "default";
              xcursor-size = 24;
            };

            hotkey-overlay.skip-at-startup = [];

            environment.EDITOR = "nvim";

            window-rule = {
              _children = [
                {
                  match = {
                    _props = {title = "termfilechooser";};
                  };
                  open-floating = true;
                  open-focused = true;
                  min-height = 720;
                  max-height = 720;
                  max-width = 1300;
                  min-width = 1300;
                }
              ];
            };
          }
          // outputs;
      };
    };
  };

  chimera.wayland.mirror = {
    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.wl-mirror];
    };
  };
}
