{
  den,
  __findFile,
  ...
}: {
  den.aspects.rei = {
    includes = [
      <den/primary-user>
      <chimera/shell>
      (den.batteries.user-shell "fish")
      <chimera/batteries/privileged-user>

      <chimera/wayland/niri>
      <chimera/wayland/vicinae>
      # <chimera/desktop-shells/noctalia>

      <chimera/fish>
      <chimera/apps/coreutils>
      <chimera/browser/firefox>
      <chimera/dev/base>
      <chimera/pwn>
      <chimera/apps/yazi>
    ];
  };
  den.hosts.x86_64-linux.machina-mori.users.rei = {};
}
