{ inputs, chimera, ... }:
{
  chimera.helix = {
    homeManager =
      { pkgs, ... }:
      {
        home.sessionVariables = {
          EDITOR = "hx";
          VISUAL = "hx";
          EDIR_EDITOR = "hx";
        };
        programs.helix = {
          enable = true;

          settings = {
            editor = {
              color-modes = true;
              cursorcolumn = true;
              cursorline = true;
              end-of-line-diagnostics = "error";
              inline-diagnostics.cursor-line = "hint";
              line-number = "relative";
              lsp.display-inlay-hints = true;
              rainbow-brackets = true;
              soft-wrap.enable = true;
              indent-guides = {
                render = true;
                skip-levels = 1;
              };
              cursor-shape = {
                insert = "bar";
                normal = "block";
                select = "underline";
              };
              shell = [
                "bash"
                "-c"
              ];
            };
          };
        };
      };
  };
}
