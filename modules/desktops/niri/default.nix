{
  chimera,
  inputs,
  lib,
  niri-lib,
  den,
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
        imports = [inputs.niri.nixosModules.niri];
        nixpkgs.overlays = [inputs.niri.overlays.niri];

        systemd.user.services.niri-flake-polkit.enable = false;

        programs.niri = {
          enable = true;
          package = pkgs.niri-unstable;
        };
        niri-flake.cache.enable = true;
      };
      homeManager = {
        config,
        lib,
        pkgs,
        host,
        ...
      }: {
        home = {
          sessionVariables = {
            EDITOR = "nvim";
          };
          packages = with pkgs; [
            xwayland-satellite
            kitty
          ];
        };

        xdg.portal = {
          enable = true;
          extraPortals = with pkgs; [xdg-desktop-portal-gtk xdg-desktop-portal-gnome];
          config.niri = {
            "org.freedesktop.impl.portal.ScreenCast" = ["gnome"];
            "org.freedesktop.impl.portal.FileChooser" = ["gtk"];
          };
        };

        programs.niri = {
          settings = {
            prefer-no-csd = true;
            hotkey-overlay.skip-at-startup = true;
            environment = {
              EDITOR = "nvim";
            };
            input.mouse = {
              accel-speed = -0.6;
            };
            #
            # outputs."eDP-1" = {
            #   mode = {
            #     width = host.primaryDisplay.width;
            #     height = host.primaryDisplay.height;
            #   };
            #   scale = 1.0;
            #   position.x = 0;
            #   position.y = 0;
            # };
            #
            # outputs."HDMI-A-5" = {
            #   mode = {
            #     width = hostConfig.primaryDisplay.width;
            #     height = hostConfig.primaryDisplay.height;
            #   };
            #   scale = 1.0;
            #   position.x = 0;
            #   position.y = 0;
            # };
            #
            overview.workspace-shadow.enable = false;
            spawn-at-startup = [
              {command = ["sway-audio-idle-inhibit"];}
              {command = ["easyeffects"];}
              {
                command = [
                  "systemctl"
                  "--user"
                  "restart"
                  "xdg-desktop-portal-gtk"
                ];
              }
            ];
          };
        };

        services.cliphist.enable = true;
      };
    };

    dms = {
      includes = [chimera.wayland._.niri];

      nixos = {pkgs, ...}: {
        services.displayManager.dms-greeter = {
          enable = true;
          compositor.name = "niri";
          package = inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default;

          configHome = "/home/oxce5";

          logs = {
            save = true;
            path = "/tmp/dms-greeter.log";
          };
        };
      };
      homeManager = {
        imports = [
          inputs.dms.homeModules.dank-material-shell
          inputs.dms.homeModules.niri
        ];

        programs.dank-material-shell = {
          enable = true;

          systemd = {
            enable = true;
            restartIfChanged = true;
          };

          niri = {
            # enableKeybinds = true;
            includes = {
              enable = true;

              override = true;
              originalFileName = "hm";
              filesToInclude = [
                "alttab"
                "binds"
                "colors"
                "layout"
                "outputs"
                "wpblur"
                "blur"
                "windowrules"
              ];
            };
          };

          enableSystemMonitoring = true;
          enableVPN = true;
          enableDynamicTheming = true;
          enableAudioWavelength = true;
          enableCalendarEvents = true;
        };
      };
    };
  };
}
