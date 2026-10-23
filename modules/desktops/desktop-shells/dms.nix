{
  chimera,
  inputs,
  ...
}: {
  # parked; see AGENTS.md
  chimera.desktop-shells.dms = {
    includes = [
      chimera.desktop-shells.common
      chimera.theming.declarative
    ];
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
}
