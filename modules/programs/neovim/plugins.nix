# chimera.nvf.plugins — lazy-loaded extras for the full profile only.
{...}: {
  chimera.nvf.plugins = {
    homeManager = {pkgs, ...}: {
      programs.nvf.settings.vim.lazy.plugins = {
        "grug-far.nvim" = {
          package = pkgs.vimPlugins.grug-far-nvim;
          cmd = ["GrugFar" "GrugFarWithin"];
          setupModule = "grug-far";
          setupOpts = {};
        };
        "precognition.nvim" = {
          package = pkgs.vimPlugins.precognition-nvim;
          event = ["BufReadPost" "BufNewFile"];
          setupModule = "precognition";
          setupOpts = {};
        };
        "tiny-glimmer.nvim" = {
          package = pkgs.vimPlugins.tiny-glimmer-nvim;
          event = ["TextYankPost"];
          setupModule = "tiny-glimmer";
          setupOpts = {};
        };
        "todo-comments.nvim" = {
          package = pkgs.vimPlugins.todo-comments-nvim;
          event = ["BufReadPost" "BufNewFile"];
          setupModule = "todo-comments";
          setupOpts = {};
        };
        "guess-indent.nvim" = {
          package = pkgs.vimPlugins.guess-indent-nvim;
          event = ["BufReadPost" "BufNewFile"];
          setupModule = "guess-indent";
          setupOpts = {};
        };
        "ts-comments.nvim" = {
          package = pkgs.vimPlugins.ts-comments-nvim;
          event = ["BufReadPost" "BufNewFile"];
          setupModule = "ts-comments";
          setupOpts = {};
        };
        # key must equal the package pname (R.nvim, not r-nvim)
        "R.nvim" = {
          package = pkgs.vimPlugins.R-nvim;
          ft = ["r" "rmd" "quarto"];
        };
      };
    };
  };
}
