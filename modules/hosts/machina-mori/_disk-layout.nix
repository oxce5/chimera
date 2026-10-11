{
  disko.devices = {
    nodev."/" = {
      type = "nodev";
      fsType = "tmpfs";
      mountOptions = [
        "mode=0755"
        "size=512M"
      ];
    };

    disk = {
      main = {
        type = "disk";
        device = "/dev/vda";
        destroy = false;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
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
            persist = {
              size = "4G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/persist";
              };
            };
            home = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/home";
              };
            };
          };
        };
      };

      store = {
        type = "disk";
        device = "/dev/vdb";
        destroy = true;
        content = {
          type = "gpt";
          partitions = {
            nixstore = {
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
          };
        };
      };
    };
  };
}
