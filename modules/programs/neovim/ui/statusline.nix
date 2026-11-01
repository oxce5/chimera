{...}: {
  chimera.nvf.ui = {
    homeManager = {lib, ...}: {
      programs.nvf.settings.vim = {
        statusline.lualine.enable = true;
      };
    };
  };
}
