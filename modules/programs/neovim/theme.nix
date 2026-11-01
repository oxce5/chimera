# chimera.nvf.theme — imperative base16 palette from noctalia+matugen.
#
# The palette must stay imperative: noctalia re-renders it on every wallpaper
# change (user template in ./noctalia/, rendered to the noctalia state dir)
# and signals running nvim via SIGUSR1. nvf owns the config as a store package
# (NVIM_APPNAME=nvf), so nothing under ~/.config/nvim is on the runtimepath
# anymore — the module is loaded from the state dir via package.path instead.
# Transparency lives inside the template's setup() so it survives every
# re-render, not in nvf (which would apply it once, then lose it).
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
