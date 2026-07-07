{ den, __findFile, ...}: {
  den.aspects.oxce5 = {
    includes = [
      <den/primary-user>
      <chimera/shell>
      (den.batteries.user-shell "fish")
    ];
    user = {
      extraGroups = [
        "docker"
        "wireshark"
      ];
    };
  };
  den.hosts.x86_64-linux.overlord.users.oxce5 = {};
}
