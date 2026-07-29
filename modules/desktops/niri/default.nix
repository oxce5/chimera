{
  chimera,
  inputs,
  ...
}: {
  chimera.wayland.provides = {
    host,
    user,
    ...
  }: {
    includes = [chimera.wayland._.base];

    niri = {
      nixos = {
        config,
        pkgs,
        ...
      }: {
        imports = [inputs.niri-nix.nixosModules.default];
        programs.niri = {
          enable = true;
          package = inputs.niri-flake.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable;
        };
      };
      homeManager = {
        config,
        lib,
        pkgs,
        host,
        ...
      }: {
        home.packages = with pkgs; [
          xwayland-satellite
          kitty
        ];
        services.cliphist.enable = true;

        wayland.windowManager.niri = {
          enable = true;
          package = inputs.niri-flake.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable;
          settings = {
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
              focus-ring = {
                width = 4;
              };
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

            spawn-at-startup = [
              "noctalia"
              "easyeffects"
            ];

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
          };
        };
      };
    };
  };
}
