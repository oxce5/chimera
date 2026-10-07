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
              # When this host goes volatile (chimera.impermanence.volatile-root)
              # this LV stops being / and becomes the preservation store at
              # /persist instead — same LV, same uuid, no mkfs. Its ~1.2G of
              # ex-/ content has to be dealt with at that point.
              priority = 1000;
              size = "25%FREE";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
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

    # /nix is scratch: a stale store is pure garbage, and keeping it across
    # deploys hides problems (dead symlinks in the GC roots, closures built
    # against a different config). So drop NIXSTORE before disko runs and let
    # it be recreated empty. Doing it here rather than in the disko spec also
    # frees the extents it held, which is what leaves room for the volumes
    # that take a percentage of the free space.
    system.build.diskoScript = lib.mkForce (pkgs.writeShellScript "diskoScript" ''
      PATH=${lib.makeBinPath [pkgs.lvm2 pkgs.util-linux]}:$PATH
      # lvremove refuses nothing, but a mounted LV would leave the mountpoint
      # shadowed by a fresh, empty filesystem.
      umount /nix /home /workspace 2>/dev/null || true
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
