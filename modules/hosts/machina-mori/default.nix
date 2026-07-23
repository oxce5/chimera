{chimera, ...}: {
  den.aspects.machina-mori = {
    includes = with chimera; [
      vm
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
      imports = [<nixpkgs/nixos/modules/profiles/qemu-guest.nix>];
      boot = {
        loader.systemd-boot.enable = true;
        loader.timeout = 0;
        consoleLogLevel = 3;
      };
      networking.networkmanager.enable = true;

      hardware.enableRedistributableFirmware = false;
      services.printing.enable = false;
      services.avahi.enable = false;

      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "niri-session";
            user = "rei";
          };
        };
      };

      users.privilegedGroups = ["audio" "docker"];
      virtualization.docker.enable = true;
    };
    homeManager = {
      wayland.windowManager.niri.settings = {
        input.mod-key = "Alt";
      };
    };
  };
}
