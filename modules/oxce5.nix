{__findFile, ...}: {
  den.aspects.oxce5 = {
    includes = [
      <den/primary-user>
      # <chimera/helix/with-tools>
      # <chimera/nushell>
      <chimera/shell>
    ];
    nixos.users.users.oxce5 = {
      # openssh.authorizedKeys.keys = [
      #   "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIezBKQfXf4ZHTKyCBavmlIXVFhJ7xd4MltEubJe9Kxe quasi@hades"
      #   "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBQ8s7HeNm2rc4jxPdontGgXy3am1qSkXDbOgnT4Kz+J quasi@zagreus"
      # ];
      extraGroups = [
        "docker"
        "wireshark"
      ];
    };
  };
  den.hosts.x86_64-linux.overlord.users.oxce5 = {};
}
