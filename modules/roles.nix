{
  den,
  __findFile,
  ...
}: {
  # NOTE: aspects defined here reference each other by path (`<chimera/...>`),
  # not via a `chimera` module argument. Taking `chimera` as an argument makes
  # path lookup self-referential and it falls through to the NIX search path.
  chimera = {
    # The floor every user account in the fleet stands on: an interactive
    # shell, a wayland session, and the file manager. Everything else is
    # layered on top by a role.
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

    # The daily driver: full desktop, GUI apps, and the dev/ai toolchains.
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
        <chimera/dev/base>
        <chimera/dev/sessions>
        <chimera/pwn>
      ];
    };
  };
}
