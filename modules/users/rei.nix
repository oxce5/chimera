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
      ({user}: { nixos.users.users.${user.userName}.hashedPassword = "$6$9O1fV1iB4koyWdpw$lTDeilYqeuF2H2/rtmc1qxwjvx3SUbBcs71EKICZxQaGuxciSBPicgShCQ56aZ..QvirueLNna6w0avGRPqX21"; })
      <chimera/batteries/privileged-user>

      <chimera/wayland/niri>
      <chimera/wayland/vicinae>
      # <chimera/desktop-shells/noctalia>

      <chimera/fish>
      <chimera/apps/coreutils-slim>
      <chimera/browser/pentest>
      <chimera/dev/base>
      <chimera/dev/sessions>
      <chimera/pwn>
      <chimera/apps/yazi>
    ];
  };
  den.hosts.x86_64-linux.machina-mori.users.rei = {};
}
