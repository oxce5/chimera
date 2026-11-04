# chimera.nvf.plugins search/replace and precognition, configured via NVF modules.
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
