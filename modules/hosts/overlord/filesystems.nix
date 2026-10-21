{lib, ...}: {
  den.aspects.overlord.nixos = {
    boot = {
      tmp.cleanOnBoot = true;
      loader.systemd-boot.configurationLimit = 10;
      initrd.availableKernelModules = ["btrfs"];
    };

    fileSystems."/tmp".options = lib.mkForce [
      "mode=1777"
      "size=4G"
    ];
    fileSystems."/var/tmp".options = lib.mkForce [
      "mode=1777"
      "size=2G"
    ];
  };
}
