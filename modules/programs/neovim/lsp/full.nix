# chimera.nvf.lsp.full — heavy languages for the full profile (overlord).
# Adds to whatever chimera.nvf.lsp.light already enabled; the profiles merge.
{...}: {
  chimera.nvf.lsp.full = {
    homeManager = {pkgs, ...}: {
      programs.nvf.settings.vim = {
        languages = {
          nix.enable = true;
          rust.enable = true;
          go.enable = true;
          java.enable = true;
          # no separate javascript module — typescript covers JS tooling
          typescript.enable = true;
          html.enable = true;
          css.enable = true;
        };

        # jdtls rides along with the java language instead of the shared
        # lazy-plugin list; only the full profile pays for it.
        lazy.plugins."nvim-jdtls" = {
          package = pkgs.vimPlugins.nvim-jdtls;
          ft = ["java"];
        };
      };
    };
  };
}
