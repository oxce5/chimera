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
          package = pkgs.niri;
          # niri's module adds nautilus to services.dbus.packages for
          # xdg-desktop-portal-gnome's FileChooser, but chimera.xdg forces
          # FileChooser to termfilechooser, so nautilus (~1.1 GiB) is dead weight.
          useNautilus = false;
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
          # Required for Xwayland applications (burpsuite, etc.) under niri.
          xwayland-satellite
          kitty
        ];
        services = {
          cliphist.enable = true;
          # Default wallpaper daemon. Desktop shells manage the wallpaper
          # themselves and force-disable this (see desktop-shells common).
          awww.enable = true;
        };

        wayland.windowManager.niri = {
          enable = true;
          package = pkgs.niri;
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

            output = lib.mapAttrsToList (name: d:
              {
                _args = [name];
                mode = "${toString d.width}x${toString d.height}${lib.optionalString ((d.refreshRate or null) != null) "@${toString d.refreshRate}"}";
                transform = d.transform or "normal";
              }
              // lib.optionalAttrs ((d.position or null) != null) {
                position._props = {
                  x = d.position.x;
                  y = d.position.y;
                };
              })
            host.outputs;

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
          };
        };
      };
    };
    mirror = {
      homeManager = {pkgs, ...}: {
        home.packages = [pkgs.wl-mirror];
      };
    };
  };
}
