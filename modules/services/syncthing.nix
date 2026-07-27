{chimera, ...}: {
  chimera.services._.syncthing = {
    nixos = {
      services.syncthing = {
        enable = true;
        openDefaultPorts = true;
      };
    };
  };
}
