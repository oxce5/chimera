# Aspects for throwing away everything the config does not explicitly keep.
#
# Two separate things live here, deliberately at different levels of ambition:
#
#   ephemeral-tmp  — live today. /tmp and /var/tmp are the only places on a
#                    NixOS box where state nobody declared piles up, and on
#                    both the laptop and the VM that state is worthless by
#                    definition.
#   volatile-root  — a skeleton. Everything else is still persistent; this is
#                    the shape the full version takes.
#
# Both are host-agnostic on purpose: the roles in modules/machines.nix pull them
# in per host, so overlord can join without duplicating anything. Anything a
# specific host must not lose is declared by that host (see
# modules/hosts/machina-mori/impermanence.nix) rather than here.
{inputs, ...}: {
  chimera.impermanence.provides = {
    ephemeral-tmp.nixos = {lib, ...}: {
      # size=100% is systemd's own default (half of RAM). Stay relative
      # because memory is assigned outside this config — in libvirt for the VM.
      fileSystems."/tmp" = {
        device = "tmpfs";
        fsType = "tmpfs";
        options = [
          "mode=1777"
          "size=100%"
        ];
      };
      fileSystems."/var/tmp" = {
        device = "tmpfs";
        fsType = "tmpfs";
        options = [
          "mode=1777"
          "size=100%"
        ];
      };
    };

    # The full volatile root, parked. The preserveAt block below is written out
    # rather than commented so the option names are type-checked on every eval,
    # but preservation does nothing unless `enable` is true — the built system
    # is byte-identical to not having this aspect at all.
    #
    # Rolling it out takes more than flipping `enable`, because the state has to
    # live somewhere real:
    #   1. Give the host a persistent mount for it and mount that at /persist.
    #      `persistentStoragePath` defaults to the attribute name, so
    #      preserveAt."/persist" needs no further wiring. Hosts that use disko
    #      get there by pointing their root LV at /persist instead of / — same
    #      LV, same uuid, and no mkfs, since blkid still recognises the ext4.
    #   2. Make / a tmpfs (`disko.devices.nodev."/"` for disko hosts).
    #   3. Set fileSystems."/persist".neededForBoot and
    #      fileSystems."/nix".neededForBoot — machine-id and the nix database are
    #      read from the initrd, so the mounts have to exist that early.
    volatile-root.nixos = {lib, ...}: {
      imports = [inputs.preservation.nixosModules.default];

      preservation = {
        enable = false;

        preserveAt."/persist" = {
          files = [
            # Read before almost anything else runs.
            {
              file = "/etc/machine-id";
              inInitrd = true;
            }
            # `symlink` rather than a bind mount so a half-written key is never
            # observable in place; configureParent creates /persist/etc.
            {
              file = "/etc/ssh/ssh_host_ed25519_key";
              how = "symlink";
              configureParent = true;
            }
            {
              file = "/etc/ssh/ssh_host_rsa_key";
              how = "symlink";
              configureParent = true;
            }
            {
              file = "/var/lib/systemd/random-seed";
              how = "symlink";
              inInitrd = true;
              configureParent = true;
            }
          ];

          directories = [
            # The nix database. Without it every rebuild re-registers the whole
            # store, which is slow enough to be worth preserving.
            {
              directory = "/var/lib/nixos";
              inInitrd = true;
            }
            # Past boots are the only record of what a machine did last week.
            "/var/log"
            # Hand-installed tooling and payloads that no Nix expression owns.
            "/opt"
          ];
        };
      };
    };
  };
}
