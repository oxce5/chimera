{pkgs, ...}: {
  den.aspects.machina-mori.nixos = {
    boot.initrd.services.lvm.enable = true;
    boot.initrd.availableKernelModules = ["virtio_blk" "virtio_pci" "virtio"];
    boot.initrd.kernelModules = ["dm_mod"];

    # boot.initrd.systemd.services.lvm-activate = {
    #   description = "Activate LVM volume group pool";
    #   wantedBy = ["initrd.target"];
    #   after = ["systemd-udevd.service"];
    #   before = ["sysroot.mount"];
    #   unitConfig.DefaultDependencies = false;
    #   serviceConfig.Type = "oneshot";
    #   script = ''
    #     ${pkgs.lvm2}/bin/lvm vgchange -ay pool
    #   '';
    # };

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
  };
}
