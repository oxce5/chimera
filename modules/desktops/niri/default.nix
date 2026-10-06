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
            //
            # home-manager's toKDL serializes list values as `node { - item }`
            # (rejected by niri), and the attr `output` can only appear once,
            # so each connector is an independent top-level key. The key IS
            # the full node name; the value is that node's body.
            (lib.mapAttrs'
              (
                name: d: let
                  refresh = d.refresh or null;
                in
                  lib.nameValuePair ''output "${name}"'' {
                    mode = "${toString d.width}x${toString d.height}${lib.optionalString (refresh != null) "@${toString refresh}"}";
                    position._props = {
                      x = d.x or 0;
                      y = d.y or 0;
                    };
                    scale = d.scaling or 1.0;
                    transform = d.transform or "normal";
                  }
                  // lib.optionalAttrs (d.vrr or false) {
                    variable-refresh-rate = "on-demand";
                  }
                  // lib.optionalAttrs (d.primary or false) {
                    focus-at-startup = true;
                  }
              )
              host.displays);
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
