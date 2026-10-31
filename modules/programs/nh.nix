{
  chimera.apps.gui = {
    homeManager = {
      programs.nh = {
        enable = true;
        clean = {
          enable = false;
          extraArgs = "--keep-since 3d --keep 3 --nogcroots";
          dates = "daily";
        };

        flake = "/home/oxce5/Projects/chimera";
      };
    };
  };
}
