{...}: {
  chimera.nvf.ui = {
    homeManager = {lib, ...}: {
      programs.nvf.settings.vim = {
        binds.whichKey.enable = true;
        binds.whichKey.setupOpts = {
          preset = "helix";
          delay = 0;
          icons.mappings = lib.generators.mkLuaInline "vim.g.have_nerd_font";
          spec = [
            {
              "@1" = "<leader>f";
              group = "File/Find";
              mode = ["n" "v"];
            }
            {
              "@1" = "<leader>s";
              group = "Search";
              mode = ["n" "v"];
            }
            {
              "@1" = "<leader>g";
              group = "Git";
              mode = ["n" "v"];
            }
            {
              "@1" = "<leader>gh";
              group = "Git Hunk";
              mode = ["n" "v"];
            }
            {
              "@1" = "<leader>c";
              group = "Code";
              mode = ["n" "v"];
            }
            {
              "@1" = "<leader>d";
              group = "Debug";
              mode = ["n" "v"];
            }
            {
              "@1" = "<leader>u";
              group = "UI";
              mode = ["n" "v"];
            }
            {
              "@1" = "<leader>x";
              group = "Diagnostics/Quickfix";
              mode = ["n" "v"];
            }
            {
              "@1" = "<leader>b";
              group = "Buffer";
              mode = ["n" "v"];
            }
            {
              "@1" = "<leader>t";
              group = "Toggle";
              mode = ["n" "v"];
            }
            {
              "@1" = "[";
              group = "Prev";
            }
            {
              "@1" = "]";
              group = "Next";
            }
            {
              "@1" = "g";
              group = "Goto";
            }
            {
              "@1" = "gs";
              group = "Surround";
            }
          ];
        };
      };
    };
  };
}
