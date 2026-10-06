{chimera, ...}: {
  den.aspects.overlord = {
    includes = with chimera; [
      laptop
      apps._.openrgb
      virt._.host
      virt._.docker
    ];
  };

  den.hosts.x86_64-linux.overlord = {
    users.oxce5.classes = ["homeManager"];
    outputs = {
      eDP-1 = {
        width = 1920;
        height = 1080;
        refreshRate = 60;
      };
      HDMI-A-5 = {
        width = 1920;
        height = 1080;
      };
    };
  };

  den.aspects.overlord.nixos = {
    pkgs,
    config,
    ...
  }: {
    facter.reportPath = ./_facter.json;
    boot = {
      kernelPackages = pkgs.linuxPackages_zen;
      loader.systemd-boot.enable = true;
    };
    networking = {
      networkmanager.enable = true;
      hosts = {
        "192.168.1.254" = ["bastion"];
      };
    };

    # Enable OpenTabletDriver
    hardware.uinput.enable = true;

    boot.kernelModules = ["uinput"];

    users.privilegedGroups = ["audio" "docker"];
    hardware.nvidia-container-toolkit.enable = true;
  };
}
