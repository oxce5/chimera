{
  den,
  __findFile,
  ...
}: {
  den.aspects.oxce5 = {
    includes = [
      <den/primary-user>
      <chimera/shell>
      (den.batteries.user-shell "fish")
      <chimera/batteries/privileged-user>

      <chimera/wayland/niri>
      <chimera/wayland/vicinae>
      <chimera/desktop-shells/noctalia>
      <chimera/easyeffects>
      <chimera/tailscale>
      <chimera/flatpak>
      <chimera/xdg>
      <chimera/fish>

      <chimera/dev/min>
      <chimera/dev/ai>
      <chimera/apps/coreutils>
      <chimera/apps/gui>
      <chimera/apps/git>
      <chimera/apps/yazi>

      <chimera/services/syncthing>
    ];
  };
  den.hosts.x86_64-linux.overlord.users.oxce5 = {};
}
