{chimera, ...}: {
  den.aspects.overlord = {
    includes = with chimera; [
      laptop
      gaming._.max
      virt._.host
      virt._.docker
      microvm._.host
    ];
  };

  den.hosts.x86_64-linux.overlord = {
    users.oxce5.classes = ["homeManager"];
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

    users.privilegedGroups = ["audio" "docker"];
    hardware.nvidia-container-toolkit.enable = true;
  };
}
