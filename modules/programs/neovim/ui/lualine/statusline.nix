{inputs, ...}: {
  chimera.nvf.ui = {
    homeManager = {
      lib,
      pkgs,
      ...
    }: {
      programs.nvf.settings.vim = let
        inherit (inputs.nvf.lib.nvim.dag) entryAnywhere;
      in {
        statusline.lualine.enable = false;

        extraPlugins = {
          lualine-nvim.package = pkgs.vimPlugins.lualine-nvim;
        };

        luaConfigRC.lualine = entryAnywhere (builtins.readFile ./lualine.lua);
      };
    };
  };
}
