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
              "@1" = "<leader><tab>";
              group = "tabs";
              mode = ["n" "v"];
            }
            {
              "@1" = "<leader>b";
              group = "buffer";
              mode = ["n" "v"];
            }
            {
              "@1" = "<leader>c";
              group = "code";
              mode = ["n" "v"];
            }
            {
              "@1" = "<leader>d";
              group = "debug";
              mode = ["n" "v"];
            }
            {
              "@1" = "<leader>f";
              group = "file/find";
              mode = ["n" "v"];
            }
            {
              "@1" = "<leader>g";
              group = "git";
              mode = ["n" "v"];
            }
            {
              "@1" = "<leader>gh";
              group = "hunks";
              mode = ["n" "v"];
            }
            {
              "@1" = "<leader>q";
              group = "quit/session";
              mode = ["n" "v"];
            }
            {
              "@1" = "<leader>s";
              group = "search";
              mode = ["n" "v"];
            }
            {
              "@1" = "<leader>t";
              group = "toggle";
              mode = ["n" "v"];
            }
            {
              "@1" = "<leader>u";
              group = "ui";
              mode = ["n" "v"];
            }
            {
              "@1" = "<leader>x";
              group = "diagnostics/quickfix";
              mode = ["n" "v"];
            }
            {
              "@1" = "[";
              group = "prev";
            }
            {
              "@1" = "]";
              group = "next";
            }
            {
              "@1" = "g";
              group = "goto";
            }
            {
              "@1" = "gs";
              group = "surround";
            }
            {
              "@1" = "z";
              group = "fold";
            }
          ];
        };
      };
    };
  };
}
