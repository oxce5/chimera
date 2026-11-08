# chimera.nvf.minimal / chimera.nvf.full — the two shipped profiles.
# minimal → machina-mori (pentest-user): base + eyecandy + light LSPs.
# full   → overlord (workstation-user): minimal + heavy LSPs + editing + extras.
{chimera, ...}: {
  chimera.nvf.minimal = {
    includes = [
      chimera.nvf
      chimera.nvf.theme
      chimera.nvf.ui
      chimera.nvf.nav
      chimera.nvf.treesitter
      chimera.nvf.git
      chimera.nvf.lsp
      chimera.nvf.lsp.light
      chimera.nvf.lint
      chimera.nvf.lint.light
    ];
  };

  chimera.nvf.full = {
    includes = [
      chimera.nvf.minimal
      chimera.nvf.lsp.full
      chimera.nvf.lint.full
      chimera.nvf.code
      chimera.nvf.plugins
    ];
  };
}
