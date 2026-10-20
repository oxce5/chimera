{
  den,
  __findFile,
  ...
}: {
  # reference siblings by path, never via a `chimera` arg (see AGENTS.md)
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
        # HM half of pentest-helium; its nixos half comes via the vm host role
        <chimera/browser/pentest-helium>
        <chimera/dev/base>
        <chimera/dev/sessions>
        <chimera/pwn>
        # only for its homeManager half; host-role HM content is inert
        <chimera/virt/headless>
      ];
    };
  };
}
