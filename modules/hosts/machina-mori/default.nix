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
      services.pipewire = {
        alsa.enable = lib.mkForce false;
        alsa.support32Bit = lib.mkForce false;
        jack.enable = lib.mkForce false;
      };
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

      virtualisation.docker.enable = lib.mkForce false;
      users.privilegedGroups = ["audio" "video" "render"];

      # Keep the store from filling / on big nixpkgs updates. The VM only runs
      # for a few hours, so GC-on-boot catches the previous session's garbage;
      # min-free/max-free additionally auto-GC mid-build when space runs low.
      nix = {
        optimise.automatic = lib.mkForce true;
        gc = {
          automatic = true;
          options = "--delete-older-than 14d --max-freed 20G";
        };
        settings = {
          keep-outputs = lib.mkForce false;
          keep-derivations = lib.mkForce false;
          auto-optimise-store = lib.mkForce false;
          min-free = "2G";
          max-free = "10G";
        };
      };
      # Run the GC unit once at boot instead of relying on a daily timer that
      # likely never fires within the VM's short uptime.
      systemd.services."nix-gc".wantedBy = lib.mkForce ["multi-user.target"];
    };
  };
}
