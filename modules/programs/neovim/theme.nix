# chimera.nvf.theme — imperative base16 palette from noctalia+matugen.
{...}: {
  chimera.nvf.theme = {
    homeManager = {pkgs, ...}: {
      programs.nvf.settings.vim.lazy.plugins."base16-nvim" = {
        package = pkgs.vimPlugins.base16-nvim;
        # Start plugin: loads (and runs `after`) at startup, palette applies
        # before other plugins' highlights matter.
        priority = 1000;
        after = ''
          local dir = (vim.env.XDG_STATE_HOME or (vim.env.HOME .. '/.local/state')) .. '/noctalia'
          package.path = dir .. '/?.lua;' .. package.path
          local ok, matugen = pcall(require, 'matugen')
          if ok then matugen.setup() end
        '';
      };

      xdg.configFile = {
        # Read by noctalia; settings.toml (runtime state) must not define the
        # same [theme.templates.user.nvim-matugen] table or it overrides this.
        "noctalia/templates.toml".source = ./noctalia/templates.toml;
        "noctalia/templates/nvim.lua".source = ./noctalia/nvim.lua;
      };
    };
  };
}
