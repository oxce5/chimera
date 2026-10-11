{...}: {
  den.aspects.machina-mori.nixos = {
    boot.initrd = {
      availableKernelModules = [
        "btrfs"
        "virtio_blk"
        "virtio_pci"
        "virtio"
      ];
      services.lvm.enable = true;
    };
  };
}
