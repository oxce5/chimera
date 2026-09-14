{pkgs, ...}: {
  den.aspects.machina-mori.nixos = {
    boot.initrd = {
      availableKernelModules = ["virtio_blk" "virtio_pci" "virtio"];
      services.lvm.enable = true;
    };

    # Lives on a second disk, outside the disko layout, so it survives reinstalls.
    fileSystems."/workspace" = {
      device = "/dev/disk/by-label/workspace";
      fsType = "ext4";
    };
  };
}
