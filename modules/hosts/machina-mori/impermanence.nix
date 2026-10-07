# What this host must keep when it goes volatile. The generic side of the setup
# lives in chimera.impermanence.volatile-root; this is the part that is specific
# to machina-mori, i.e. state that a future full volatile root would otherwise
# wipe on every boot.
#
# Precedent: whoever enables a stateful service owns the declaration of where
# that service keeps state. chimera.pwn.c2 turns Sliver on, so this host — the
# only one that runs the server — is what keeps /var/lib/sliver alive.
#
# Note this is inert today: preservation.enable is false in the generic aspect.
{...}: {
  den.aspects.machina-mori.nixos = {lib, ...}: {
    preservation.preserveAt."/persist".directories = [
      # Sliver server state: implants, sessions, engagement data. The one thing
      # on this box that must never be wiped.
      "/var/lib/sliver"
    ];

    # /workspace (NIXWORK) and /home (HOMEROOT) need no declaration: they are
    # LVs in their own right, so they survive both reboots and nixos-anywhere
    # deploys untouched.
  };
}
