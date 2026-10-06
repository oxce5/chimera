{
  chimera,
  __findFile,
  ...
}: {
  den.aspects.rei.includes = [
    <den/primary-user>
    # <chimera/desktop-shells/noctalia>
    ({user}: {nixos.users.users.${user.userName}.hashedPassword = "$6$9O1fV1iB4koyWdpw$lTDeilYqeuF2H2/rtmc1qxwjvx3SUbBcs71EKICZxQaGuxciSBPicgShCQ56aZ..QvirueLNna6w0avGRPqX21";})
    chimera.pentest-user
  ];
  den.hosts.x86_64-linux.machina-mori.users.rei = {};
}
