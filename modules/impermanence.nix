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

    # The volatile root, live on machina-mori. Rolling it out took three pieces
    # of host-side wiring that this aspect does not and cannot do itself:
    #   1. A persistent mount at /persist. `persistentStoragePath` defaults to
    #      the attribute name, so preserveAt."/persist" needs no further
    #      wiring. disko hosts get there by pointing their root LV at /persist
    #      instead of / — same LV, same uuid, no mkfs, since blkid still
    #      recognises the ext4. See modules/hosts/machina-mori/disko.nix.
    #   2. / as a tmpfs (`disko.devices.nodev."/"` for disko hosts).
    #   3. fileSystems."/persist".neededForBoot and fileSystems."/nix".neededForBoot,
    #      because machine-id and the nix database are read from the initrd.
    #
    # Only what a running machine cannot reconstruct is listed here. Anything
    # the config re-derives each boot is deliberately absent — see the nix
    # database note below, which is the easy one to get wrong.
    volatile-root.nixos = {lib, ...}: {
      imports = [inputs.preservation.nixosModules.default];

      preservation = {
        enable = true;

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
            # Without this the machine reseeds entropy on every boot.
            {
              file = "/var/lib/systemd/random-seed";
              how = "symlink";
              inInitrd = true;
              configureParent = true;
            }
          ];

          directories = [
            # The connection identity: secret_key, seen-bssids, and the leases
            # keyed by interface name. Losing it gives the host a new identity
            # on every boot, which churns anything that pins it — tailscale,
            # paired remotes, DHCP reservations.
            "/var/lib/NetworkManager"
            # NOT the nix database, despite what it used to be commented as:
            # /var/lib/nixos holds auto-subuid-map, declarative-users,
            # declarative-groups, uid-map and gid-map, all of which activation
            # rewrites from the config every boot. The real nix DB is
            # /nix/var/nix/{db,gcroots,profiles}, which lives on NIXSTORE and is
            # already wiped by the host's diskoScript on every deploy.
            #
            # NOT /var/log or /opt either: /opt does not exist on either host,
            # and the journal is transient by nature. Add them back per host if
            # past boots turn out to matter.
          ];
        };
      };
    };
  };
}
