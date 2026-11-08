# chimera.nvf.plugins search/replace and precognition.
{
  chimera.nvf.plugins = {
    homeManager = {pkgs, ...}: {
      programs.nvf.settings.vim = {
        utility.grug-far-nvim.enable = true;

        lazy.plugins."precognition.nvim" = {
          package = pkgs.vimPlugins.precognition-nvim;
          event = ["BufReadPost" "BufNewFile"];
          setupModule = "precognition";
          setupOpts = {};
        };
      };
    };
  };
}
