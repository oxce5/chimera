# chimera.nvf.lsp.light — light language servers for the minimal profile
# (machina-mori): shell/data formats plus python, no heavyweight toolchains.
{...}: {
  chimera.nvf.lsp.light = {
    homeManager = {...}: {
      programs.nvf.settings.vim.languages = {
        bash.enable = true;
        python.enable = true;
        yaml.enable = true;
        json.enable = true;
        toml.enable = true;
        markdown.enable = true;
        lua.enable = true;
      };
    };
  };
}
