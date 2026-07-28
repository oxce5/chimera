{
  chimera.apps._.gui = {
    homeManager = {
      config,
      pkgs,
      ...
    }: {
      programs.nh = {
        enable = true;
        clean.enable = false;
        clean.extraArgs = "--keep-since 4d --keep 5";
        flake = "/home/oxce5/.flake";
      };
    };
  };
}
