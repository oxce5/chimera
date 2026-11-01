{...}: {
  chimera.nvf.ui = {
    homeManager = {lib, ...}: {
      programs.nvf.settings.vim = {
        visuals.rainbow-delimiters.enable = true;
      };
    };
  };
}
