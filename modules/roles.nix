{
  den,
  __findFile,
  ...
}: {
  # NOTE: aspects defined here reference each other by path (`<chimera/...>`),
  # not via a `chimera` module argument. Taking `chimera` as an argument makes
  # path lookup self-referential and it falls through to the NIX search path.
  chimera = {
    desktop-base = {
      includes = [
        <chimera/shell>
        (den.batteries.user-shell "fish")
        <chimera/batteries/privileged-user>

        <chimera/wayland/niri>
        <chimera/wayland/vicinae>

        <chimera/fish>
        <chimera/apps/yazi>
      ];
    };

    workstation-user = {
      includes = [
        <chimera/desktop-base>

        <chimera/shell/enhanced>

        <chimera/wayland/mirror>
        <chimera/wayland/screenshot>
        <chimera/wayland/cast>
        <chimera/desktop-shells/noctalia>

        <chimera/easyeffects>
        <chimera/tailscale>
        <chimera/flatpak>
        <chimera/xdg>

        <chimera/gaming/max>

        <chimera/dev/min>
        <chimera/dev/ai>
        <chimera/apps/coreutils/desktop>
        <chimera/apps/gui>
        <chimera/apps/git>

        <chimera/services/syncthing>
        <chimera/services/printing>
      ];
    };

    # The throwaway VM: a lean desktop plus the offensive tooling.
    pentest-user = {
      includes = [
        <chimera/desktop-base>

        <chimera/apps/coreutils-slim>
        <chimera/browser/pentest>
        # homeManager half of pentest-helium (the package); its nixos half
        # (/etc/chromium policies) comes via the vm host role. Mod+B stays
        # on firefox-esr - helium is launched from the launcher.
        <chimera/browser/pentest-helium>
        <chimera/dev/base>
        <chimera/dev/sessions>
        <chimera/pwn>
        # Only needed for its homeManager half (the niri portal trim): Den
        # merges homeManager content reached through a *user* role aspect.
        # `chimera.vm` is a host role, so its includes — including this one —
        # contribute nixos content but their homeManager half is inert.
        <chimera/virt/headless>
      ];
    };
  };
}
