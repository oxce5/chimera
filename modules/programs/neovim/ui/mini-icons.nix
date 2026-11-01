{...}: {
  chimera.nvf.ui = {
    homeManager = {lib, ...}: {
      programs.nvf.settings.vim = {
        mini.icons.enable = true;
        visuals.nvim-web-devicons.enable = true;
      };
    };
  };
}
