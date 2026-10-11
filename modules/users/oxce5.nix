{
  chimera,
  __findFile,
  ...
}: {
  den.aspects.oxce5.includes = [
    <den/primary-user>
    chimera.workstation-user
    chimera.storage
  ];
  den.hosts.x86_64-linux.overlord.users.oxce5 = {};
}
