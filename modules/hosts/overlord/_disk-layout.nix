{
  disko.devices = {
    nodev."/" = {
      type = "nodev";
      fsType = "tmpfs";
      mountOptions = [
        "mode=0755"
        "size=4G"
      ];
    };

    nodev."/home" = {
      type = "nodev";
      fsType = "tmpfs";
      mountOptions = [
        "mode=0755"
        "size=8G"
      ];
    };

    disk.main = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-SKHynix_HFS512GEJ4X112N_4YCAN04421170AV2Z";
      destroy = true;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "fmask=0022"
                "dmask=0022"
                "noatime"
              ];
            };
          };

          nix = {
            size = "120G";
            content = {
              type = "filesystem";
              format = "btrfs";
              mountpoint = "/nix";
              mountOptions = [
                "compress=zstd:3"
                "ssd"
              ];
            };
          };

          persist = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/persist";
            };
          };
        };
      };
    };
  };
}
