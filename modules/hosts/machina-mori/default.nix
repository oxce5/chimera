{
  chimera,
  inputs,
  ...
}: {
  den.aspects.machina-mori = {
    includes = with chimera; [
      pwn
    ];
  };

  den.hosts.x86_64-linux.machina-mori = {
    users.rei.classes = ["homeManager"];
  };

  den.aspects.machina-mori.nixos = {
    pkgs,
    config,
    ...
  }: {
    facter.reportPath = ./_facter.json;
    boot.loader.systemd-boot.enable = true;
    networking.networkmanager.enable = true;

    users.privilegedGroups = ["audio" "docker"];
  };
}
