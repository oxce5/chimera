{
  chimera,
  inputs,
  ...
}: {
  chimera.desktop-shells = {lib, ...}: {
    includes = [chimera.wayland.niri];

    common.homeManager.services.awww.enable = lib.mkForce false;

    noctalia = {
      includes = [
        chimera.desktop-shells.common
        chimera.theming.noctalia
      ];

      nixos = {
        imports = [
          inputs.noctalia.nixosModules.default
          inputs.noctalia-greeter.nixosModules.default
        ];

        disabledModules = [
          "programs/wayland/noctalia.nix"
        ];

        programs.noctalia = {
          enable = true;
          # Enables NetworkManager, Bluetooth, UPower, and a power profile service.
          recommendedServices.enable = true;
          systemd.enable = true;
        };

        services.displayManager.noctalia-greeter.enable = true;
      };

      homeManager = {pkgs, ...}: let
        msg = cmd: ["noctalia" "msg"] ++ cmd;
        panel = name: msg ["panel-toggle" name];
      in {
        home.packages = [pkgs.mpvpaper pkgs.mpv];

        wayland.windowManager.niri.settings = {
          spawn-at-startup = ["noctalia"];

          layer-rule._children = [
            {
              match._props.namespace = "^noctalia-backdrop";
              place-within-backdrop = true;
            }
          ];

          binds = {
            # Panels
            "Super+X" = {
              _props.hotkey-overlay-title = "Power Menu: Toggle";
              spawn = panel "powermenu";
            };
            "Mod+Comma" = {
              _props.hotkey-overlay-title = "Settings";
              spawn = msg ["settings-toggle"];
            };
            "Mod+Y" = {
              _props.hotkey-overlay-title = "Browse Wallpapers";
              spawn = panel "wallpaper";
            };
            "Mod+N" = {
              _props.hotkey-overlay-title = "Notification Center";
              spawn = panel "notifications";
            };
            "Mod+Shift+N" = {
              _props.hotkey-overlay-title = "Notepad";
              spawn = panel "notepad";
            };
            "Mod+Alt+L" = {
              _props.hotkey-overlay-title = "Lock Screen";
              spawn = msg ["session" "lock"];
            };
            "Ctrl+Alt+Delete" = {
              _props.hotkey-overlay-title = "Task Manager";
              spawn = panel "processlist";
            };
            "Mod+Shift+W" = {
              _props.hotkey-overlay-title = "Create window rule";
              spawn = panel "window-rules";
            };

            "Mod+P" = {
              _props.hotkey-overlay-title = "Screenshot: Region";
              spawn = msg ["screenshot-region"];
            };
            Print = {
              _props.hotkey-overlay-title = "Screenshot: Region";
              spawn = msg ["screenshot-region"];
            };
            "Mod+Alt+P" = {
              _props.hotkey-overlay-title = "Screenshot: Fullscreen";
              spawn = msg ["screenshot-fullscreen"];
            };
            "Ctrl+Print" = {
              _props.hotkey-overlay-title = "Screenshot: Fullscreen";
              spawn = msg ["screenshot-fullscreen"];
            };
            "Alt+P" = {
              _props.hotkey-overlay-title = "Screenshot: Window";
              spawn = msg ["screenshot-window"];
            };
            "Alt+Print" = {
              _props.hotkey-overlay-title = "Screenshot: Window";
              spawn = msg ["screenshot-window"];
            };
            "Shift+Print" = {
              _props.hotkey-overlay-title = "Screenshot: Annotate";
              spawn = msg ["screenshot-annotate"];
            };

            # Media
            XF86AudioRaiseVolume = {
              _props.allow-when-locked = true;
              spawn = msg ["volume-up" "3"];
            };
            XF86AudioLowerVolume = {
              _props.allow-when-locked = true;
              spawn = msg ["volume-down" "3"];
            };
            XF86AudioMute = {
              _props.allow-when-locked = true;
              spawn = msg ["volume-mute"];
            };
            XF86AudioMicMute = {
              _props.allow-when-locked = true;
              spawn = msg ["mic-mute"];
            };
            XF86AudioPause = {
              _props.allow-when-locked = true;
              spawn = msg ["media" "toggle"];
            };
            XF86AudioPlay = {
              _props.allow-when-locked = true;
              spawn = msg ["media" "toggle"];
            };
            XF86AudioPrev = {
              _props.allow-when-locked = true;
              spawn = msg ["media" "previous"];
            };
            XF86AudioNext = {
              _props.allow-when-locked = true;
              spawn = msg ["media" "next"];
            };
            "Ctrl+XF86AudioRaiseVolume" = {
              _props.allow-when-locked = true;
              spawn = msg ["volume-up" "3"];
            };
            "Ctrl+XF86AudioLowerVolume" = {
              _props.allow-when-locked = true;
              spawn = msg ["volume-down" "3"];
            };
            XF86MonBrightnessUp = {
              _props.allow-when-locked = true;
              spawn = msg ["brightness-up" "5"];
            };
            XF86MonBrightnessDown = {
              _props.allow-when-locked = true;
              spawn = msg ["brightness-down" "5"];
            };
          };
        };
      };
    };
  };
}
