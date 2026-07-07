{...}: {
  chimera.apps._.git.homeManager = {
    lib,
    pkgs,
    ...
  }: {
    programs = lib.mkMerge [
      {
        difftastic.enable = true;
        git = {
          enable = true;
          lfs.enable = true;
          signing = {
            format = "ssh";
            key = "~/.ssh/id_ed25519_sign.pub";
            signByDefault = true;
          };
          ignores = [
            ".scratch"
            "*sync-conflict*"
          ];
          settings = {
            user.name = "avg.gamer";
            user.email = "avg.gamer@proton.me";
            init.defaultBranch = "main";
            pull.rebase = true;
            rerere.enabled = true;
            column.ui = "auto";
            fetch.prune = true;
            interactive.singlekey = true;
          };
        };
      }
    ];

    home.packages = [pkgs.lazygit];
  };
}
