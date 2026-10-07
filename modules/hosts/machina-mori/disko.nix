{inputs, ...}: {
  den.aspects.machina-mori.nixos = {
    pkgs,
    config,
    lib,
    ...
  }: let
    diskoScript =
      (config.disko.devices._scripts {
        inherit pkgs;
        checked = config.disko.checkScripts;
      }).diskoScript;
  in {
    imports = [
      inputs.disko.nixosModules.disko
    ];

    disko.devices = {
      # / is a tmpfs (chimera.impermanence.volatile-root). nodev creates no
      # device, it only emits the fileSystems."/" entry, so /boot and the LVs
      # below are still the only things on disk.
      nodev."/" = {
        type = "nodev";
        fsType = "tmpfs";
        mountOptions = [
          "mode=0755"
          "size=100%"
        ];
      };

      disk = {
        main = {
          type = "disk";
          device = "/dev/vda";
          # Never wipe the disk during the disko destroy stage: keep the
          # partition table, the PV/VG and every LV (and their filesystems)
          # so that / and /home survive a redeploy. disko only creates what is
          # missing and skips mkfs on any device blkid already recognises.
          # NIXSTORE is the one exception, see system.build.diskoScript below.
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
              lvm = {
                size = "100%";
                content = {
                  type = "lvm_pv";
                  vg = "pool";
                };
              };
            };
          };
        };
      };

      lvm_vg = {
        pool = {
          type = "lvm_vg";
          lvs = {
            NIXROOT = {
              # Created before HOMEROOT, and both before NIXSTORE, so that the
              # two 25%slices are taken off the top and NIXSTORE gets the rest.
              #
              # This LV was / and is now /persist — the preservation store for
              # the volatile root (chimera.impermanence.volatile-root). Same LV,
              # same uuid, and no mkfs, since blkid still recognises the ext4.
              # It keeps the ~1.2G of old / content that predates the switch;
              # only the declared preserveAt paths are read from it.
              priority = 1000;
              size = "25%FREE";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/persist";
              };
            };
            NIXWORK = {
              priority = 1001;
              size = "3G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/workspace";
              };
            };
            HOMEROOT = {
              priority = 1002;
              size = "25%FREE";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/home";
              };
            };
            NIXSTORE = {
              size = "100%FREE";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/nix";
              };
            };
          };
        };
      };
    };

    # /persist holds everything that survives a reboot, so the initrd must be
    # able to read machine-id and the nix database out of it before the real
    # root is up. /nix needs it for the same reason: the store is a separate LV
    # and the profiles in it are read from the initrd.
    fileSystems = {
      # disko already declares /persist as /dev/pool/NIXROOT; this only adds
      # the flags, so set them without restating the device.
      "/persist".neededForBoot = true;
      "/nix".neededForBoot = true;
    };

    # /nix is scratch: a stale store is pure garbage, and keeping it across
    # deploys hides problems (dead symlinks in the GC roots, closures built
    # against a different config). So drop NIXSTORE before disko runs and let
    # it be recreated empty. Doing it here rather than in the disko spec also
    # frees the extents it held, which is what leaves room for the volumes
    # that take a percentage of the free space.
    system.build.diskoScript = lib.mkForce (pkgs.writeShellScript "diskoScript" ''
      PATH=${lib.makeBinPath [pkgs.lvm2 pkgs.util-linux]}:$PATH
      # lvremove refuses nothing, but a mounted LV would leave the mountpoint
      # shadowed by a fresh, empty filesystem. /persist is in this list because
      # NIXROOT is mounted there on every boot now that / is volatile.
      umount /nix /home /workspace /persist 2>/dev/null || true
      vgchange -ay pool || true
      if lvdisplay pool/NIXSTORE >/dev/null 2>&1; then
        echo "disko: removing existing pool/NIXSTORE for a clean store"
        # no || true: silently continuing would let disko reuse the old LV and
        # then skip mkfs on it, which is exactly the stale store we are after
        lvremove -fy pool/NIXSTORE || exit 1
      fi
      exec ${diskoScript} "$@"
    '');
  };
}
