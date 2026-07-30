{
  chimera,
  inputs,
  lib,
  ...
}: {
  chimera.desktop-shells.provides = {
    host,
    user,
    ...
  }: {
    includes = [chimera.wayland._.niri];

    dms = {
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
          inputs.dms.homeModules.niri
          inputs.dms.homeModules.dank-material-shell
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

    noctalia = {
      nixos = {
        imports = [
          inputs.noctalia.nixosModules.default
          inputs.noctalia-greeter.nixosModules.default
        ];

        disabledModules = [
          "programs/wayland/noctalia.nix"
        ];

        programs = {
          noctalia = {
            enable = true;

            # Enables NetworkManager, Bluetooth, UPower, and a power profile service.
            recommendedServices.enable = true;
            systemd.enable = true;
          };
          noctalia-greeter.enable = true;
        };
      };

      homeManager = {
        wayland.windowManager.niri.settings.binds = let
          noctalia = ["noctalia" "msg"];
        in {
          "Mod+V" = {
            _props.hotkey-overlay-title = "Clipboard Manager";
            spawn = noctalia ++ ["panel-toggle" "clipboard"];
          };
          "Mod+M" = {
            _props.hotkey-overlay-title = "Task Manager";
            spawn = noctalia ++ ["panel-toggle" "processlist"];
          };
          "Super+X" = {
            _props.hotkey-overlay-title = "Power Menu: Toggle";
            spawn = noctalia ++ ["panel-toggle" "powermenu"];
          };
          "Mod+Comma" = {
            _props.hotkey-overlay-title = "Settings";
            spawn = noctalia ++ ["settings-toggle"];
          };
          "Mod+Y" = {
            _props.hotkey-overlay-title = "Browse Wallpapers";
            spawn = noctalia ++ ["panel-toggle" "wallpaper"];
          };
          "Mod+N" = {
            _props.hotkey-overlay-title = "Notification Center";
            spawn = noctalia ++ ["panel-toggle" "notifications"];
          };
          "Mod+Shift+N" = {
            _props.hotkey-overlay-title = "Notepad";
            spawn = noctalia ++ ["panel-toggle" "notepad"];
          };
          "Mod+Alt+L" = {
            _props.hotkey-overlay-title = "Lock Screen";
            spawn = noctalia ++ ["session" "lock"];
          };
          "Ctrl+Alt+Delete" = {
            _props.hotkey-overlay-title = "Task Manager";
            spawn = noctalia ++ ["panel-toggle" "processlist"];
          };
          XF86AudioRaiseVolume = {
            _props.allow-when-locked = true;
            spawn = noctalia ++ ["volume-up" "3"];
          };
          XF86AudioLowerVolume = {
            _props.allow-when-locked = true;
            spawn = noctalia ++ ["volume-down" "3"];
          };
          XF86AudioMute = {
            _props.allow-when-locked = true;
            spawn = noctalia ++ ["volume-mute"];
          };
          XF86AudioMicMute = {
            _props.allow-when-locked = true;
            spawn = noctalia ++ ["mic-mute"];
          };
          XF86AudioPause = {
            _props.allow-when-locked = true;
            spawn = noctalia ++ ["media" "toggle"];
          };
          XF86AudioPlay = {
            _props.allow-when-locked = true;
            spawn = noctalia ++ ["media" "toggle"];
          };
          XF86AudioPrev = {
            _props.allow-when-locked = true;
            spawn = noctalia ++ ["media" "previous"];
          };
          XF86AudioNext = {
            _props.allow-when-locked = true;
            spawn = noctalia ++ ["media" "next"];
          };
          "Ctrl+XF86AudioRaiseVolume" = {
            _props.allow-when-locked = true;
            spawn = noctalia ++ ["volume-up" "3"];
          };
          "Ctrl+XF86AudioLowerVolume" = {
            _props.allow-when-locked = true;
            spawn = noctalia ++ ["volume-down" "3"];
          };
          XF86MonBrightnessUp = {
            _props.allow-when-locked = true;
            spawn = noctalia ++ ["brightness-up" "5"];
          };
          XF86MonBrightnessDown = {
            _props.allow-when-locked = true;
            spawn = noctalia ++ ["brightness-down" "5"];
          };
          "Mod+Shift+W" = {
            _props.hotkey-overlay-title = "Create window rule";
            spawn = noctalia ++ ["panel-toggle" "window-rules"];
          };
          "Ctrl+Shift+R" = {
            _props.hotkey-overlay-title = "Rename Workspace";
            spawn = noctalia ++ ["panel-open" "workspace-rename"];
          };
        };
      };
    };
  };
}
