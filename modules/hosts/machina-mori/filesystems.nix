{ ... }: {
  den.aspects.machina-mori.nixos = {
    boot.initrd.availableKernelModules = ["virtio_pci" "virtio"];
    boot.initrd.kernelModules = ["9p" "9pnet_virtio"];
  };
}
