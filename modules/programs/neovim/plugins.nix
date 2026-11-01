# chimera.nvf.plugins — lazy-loaded extras for the full profile only.
# grug-far and precognition remain here; tiny-glimmer/todo-comments moved to ui/,
# guess-indent/ts-comments moved to code/, R.nvim moved to lsp/default.nix.
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
      };
    };
  };
}
