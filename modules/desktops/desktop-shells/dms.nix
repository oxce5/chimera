{
  chimera,
  inputs,
  ...
}: {
  # Parked: nothing includes this aspect right now, it is kept so dms can be
  # swapped back in for noctalia. Include it from a user's aspect (or from
  # chimera.desktop-shells) to activate.
  chimera.desktop-shells.provides.dms = {
    includes = [
      chimera.desktop-shells._.common
      chimera.theming.provides.declarative
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
