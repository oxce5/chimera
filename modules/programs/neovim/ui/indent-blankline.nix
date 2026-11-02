{...}: {
  chimera.nvf.ui = {
    homeManager = {lib, ...}: {
      programs.nvf.settings.vim = {
        visuals = {
          indent-blankline.enable = true;
          rainbow-delimiters.enable = true;
        };

        # visuals.indent-blankline.setupOpts = {
        #   scope.highlight = [
        #     "RainbowRed"
        #     "RainbowYellow"
        #     "RainbowBlue"
        #     "RainbowOrange"
        #     "RainbowGreen"
        #     "RainbowViolet"
        #     "RainbowCyan"
        #   ];
        # };
        #
        # visuals.rainbow-delimiters.setupOpts = {
        #   highlight = [
        #     "RainbowRed"
        #     "RainbowYellow"
        #     "RainbowBlue"
        #     "RainbowOrange"
        #     "RainbowGreen"
        #     "RainbowViolet"
        #     "RainbowCyan"
        #   ];
        # };

        # lazy.plugins."indent-blankline-nvim" = {
        #   after = ''
        #     local hooks = require('ibl.hooks')
        #     local rainbow = {
        #       { group = 'RainbowRed', hex = '#E06C75' },
        #       { group = 'RainbowYellow', hex = '#E5C07B' },
        #       { group = 'RainbowBlue', hex = '#61AFEF' },
        #       { group = 'RainbowOrange', hex = '#D19A66' },
        #       { group = 'RainbowGreen', hex = '#98C379' },
        #       { group = 'RainbowViolet', hex = '#C678DD' },
        #       { group = 'RainbowCyan', hex = '#56B6C2' },
        #     }
        #     hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        #       for _, r in ipairs(rainbow) do
        #         vim.api.nvim_set_hl(0, r.group, { fg = r.hex })
        #       end
        #       vim.api.nvim_set_hl(0, 'IblIndent', { fg = vim.g.base16_gui02 or '#3b4252' })
        #     end)
        #     hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
        #   '';
        # };
      };
    };
  };
}
