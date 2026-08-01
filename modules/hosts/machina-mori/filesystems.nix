{pkgs, ...}: {
  den.aspects.machina-mori.nixos = {
    boot.initrd.services.lvm.enable = true;
    boot.initrd.availableKernelModules = ["virtio_blk" "virtio_pci" "virtio"];
    boot.initrd.kernelModules = ["dm_mod"];

    fileSystems."/" = {
      device = "/dev/pool/NIXROOT";
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
    fileSystems."/workspace" = {
      device = "/dev/disk/by-label/workspace";
      fsType = "ext4";
    };
  };
}
