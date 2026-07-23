{
  den.aspects.overlord.nixos = {
    fileSystems."/" = {
      device = "/dev/disk/by-label/ROOT";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-label/NIXBOOT";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
        "noatime"
      ];
    };
  };
}
