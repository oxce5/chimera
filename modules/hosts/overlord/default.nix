{
  chimera,
  inputs,
  ...
}: {
  den.aspects.overlord = {
    includes = with chimera; [
      laptop
      gaming._.max
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
    networking.networkmanager.enable = true;
    virtualisation.docker.enable = true;

    users.privilegedGroups = [ "docker" ];
    hardware.nvidia-container-toolkit.enable = true;
  };
}
