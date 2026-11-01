# chimera.nvf.ui — eyecandy: which-key, mini icons, visuals, noice, statusline.
{...}: {
  chimera.nvf.ui = {
    homeManager = {lib, ...}: {
      programs.nvf.settings.vim = {
        binds.whichKey.enable = true;

        mini.icons.enable = true;

        # visuals has no umbrella enable in this rev; each plugin is gated
        visuals = {
          nvim-web-devicons.enable = true;
          indent-blankline.enable = true;
          rainbow-delimiters.enable = true;
        };

        ui = {
          borders.enable = true;
          noice.enable = true;
        };

        statusline.lualine.enable = true;

        keymaps = [
          {
            key = "<leader>un";
            mode = "n";
            silent = true;
            lua = true;
            action = "function() require('noice').cmd 'dismiss' end";
            desc = "Dismiss Notifications";
          }
        ];
      };
    };
  };
}
