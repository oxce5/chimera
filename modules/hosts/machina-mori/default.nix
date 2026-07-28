{
  chimera,
  lib,
  ...
}: {
  den.aspects.machina-mori = {
    includes = with chimera; [
      vm
      virt._.guest
    ];
  };

  den.hosts.x86_64-linux.machina-mori = {
    users.rei.classes = ["homeManager"];
  };

  den.aspects.machina-mori = {
    nixos = {
      pkgs,
      config,
      ...
    }: {
      boot = {
        kernelParams = ["reboot=acpi"];
        plymouth.enable = lib.mkForce false;
        loader.systemd-boot.enable = true;
        loader.timeout = 5;
        consoleLogLevel = 3;
      };
      networking.networkmanager.enable = true;

      hardware.enableRedistributableFirmware = false;
      services = {
        printing.enable = false;
        avahi.enable = false;
        openssh = {
          enable = true;
        };

        acpid.enable = true;
      };

      services.greetd = {
        enable = true;
        restart = false;
        settings = {
          default_session = {
            command = "niri-session";
            user = "rei";
          };
        };
      };

      users.privilegedGroups = ["audio" "docker" "video" "render"];
    };
  };
}
