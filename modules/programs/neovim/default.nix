# chimera.nvf base editor: core options, autocmds, plugin-independent keymaps.
{inputs, ...}: {
  chimera.nvf = {
    homeManager = {lib, ...}: {
      imports = [inputs.nvf.homeManagerModules.default];

      programs.nvf = {
        enable = true;
        defaultEditor = true;

        settings.vim = {
          enableLuaLoader = true;

          lineNumberMode = "relNumber";
          clipboard.providers.wl-copy.enable = true;
          searchCase = "smart";
          preventJunkFiles = true;
          bell = "on";

          globals = {
            mapleader = " ";
            maplocalleader = " ";
            have_nerd_font = true;
          };

          options = {
            clipboard = "unnamedplus";
            mouse = "a";
            showmode = false;
            breakindent = true;
            expandtab = true;
            softtabstop = 2;
            shiftwidth = 2;
            tabstop = 2;
            number = true;
            signcolumn = "yes";
            updatetime = 250;
            timeoutlen = 300;
            splitright = true;
            splitbelow = true;
            list = true;
            listchars = {
              tab = "│ ";
              trail = "·";
              nbsp = "␣";
            };
            inccommand = "split";
            cursorline = true;
            scrolloff = 10;
            confirm = true;
          };

          undoFile.enable = true;

          diagnostics = {
            enable = true;
            config = {
              update_in_insert = false;
              severity_sort = true;
              float = {
                border = "rounded";
                source = "if_many";
              };
              underline = {severity = {min = 2;};};
              virtual_text = true;
              virtual_lines = false;
              jump = {
                on_jump = lib.generators.mkLuaInline "function(_, bufnr) vim.diagnostic.open_float { bufnr = bufnr, scope = 'cursor', focus = false } end";
              };
            };
          };

          luaConfigRC = {
            loader = {
              data = "vim.loader.enable()";
              before = [];
              after = ["optionsScript"];
            };
          };

          autocmds = [
            {
              event = ["TextYankPost"];
              pattern = ["*"];
              group = "highlight-yank";
              desc = "Highlight when yanking (copying) text";
              callback = lib.generators.mkLuaInline "function() vim.hl.on_yank() end";
            }
          ];

          augroups = [
            {
              name = "highlight-yank";
              clear = true;
            }
          ];

          keymaps = [
            {
              key = "<Esc>";
              mode = "n";
              silent = true;
              action = "<cmd>nohlsearch<CR>";
            }
            {
              key = "<Esc><Esc>";
              mode = "t";
              silent = true;
              action = "<C-\\><C-n>";
              desc = "Exit terminal mode";
            }
            {
              key = "<C-h>";
              mode = "n";
              silent = true;
              action = "<C-w><C-h>";
              desc = "Move focus to the left window";
            }
            {
              key = "<C-l>";
              mode = "n";
              silent = true;
              action = "<C-w><C-l>";
              desc = "Move focus to the right window";
            }
            {
              key = "<C-j>";
              mode = "n";
              silent = true;
              action = "<C-w><C-j>";
              desc = "Move focus to the lower window";
            }
            {
              key = "<C-k>";
              mode = "n";
              silent = true;
              action = "<C-w><C-k>";
              desc = "Move focus to the upper window";
            }

            {
              key = "[d";
              mode = "n";
              action = "vim.diagnostic.goto_prev";
              desc = "Previous Diagnostic";
            }
            {
              key = "]d";
              mode = "n";
              action = "vim.diagnostic.goto_next";
              desc = "Next Diagnostic";
            }
            {
              key = "[e";
              mode = "n";
              lua = true;
              action = "function() vim.diagnostic.goto_prev { severity = vim.diagnostic.severity.ERROR } end";
              desc = "Previous Error";
            }
            {
              key = "]e";
              mode = "n";
              lua = true;
              action = "function() vim.diagnostic.goto_next { severity = vim.diagnostic.severity.ERROR } end";
              desc = "Next Error";
            }

            {
              key = "[b";
              mode = "n";
              action = "<cmd>bprevious<CR>";
              desc = "Previous Buffer";
            }
            {
              key = "]b";
              mode = "n";
              action = "<cmd>bnext<CR>";
              desc = "Next Buffer";
            }
            {
              key = "<leader>bd";
              mode = "n";
              silent = true;
              action = "<cmd>bdelete<CR>";
              desc = "Delete Buffer";
            }
            {
              key = "<leader>bD";
              mode = "n";
              silent = true;
              action = "<cmd>bdelete!<CR>";
              desc = "Force Delete Buffer";
            }

            {
              key = "<leader>xd";
              mode = "n";
              silent = true;
              action = "vim.diagnostic.setloclist";
              desc = "Quickfix Diagnostics";
            }
            {
              key = "<leader>xq";
              mode = "n";
              silent = true;
              action = "<cmd>copen<CR>";
              desc = "Open Quickfix";
            }
            {
              key = "<leader>xc";
              mode = "n";
              silent = true;
              action = "<cmd>cclose<CR>";
              desc = "Close Quickfix";
            }

            {
              key = "<leader>uh";
              mode = "n";
              silent = true;
              action = "<cmd>nohlsearch<CR>";
              desc = "Clear Highlights";
            }
            {
              key = "<leader>ul";
              mode = "n";
              silent = true;
              action = "<cmd>set list!<CR>";
              desc = "Toggle List Chars";
            }
            {
              key = "<leader>uw";
              mode = "n";
              silent = true;
              action = "<cmd>set wrap!<CR>";
              desc = "Toggle Wrap";
            }
            {
              key = "<leader>ur";
              mode = "n";
              silent = true;
              action = "<cmd>set relativenumber!<CR>";
              desc = "Toggle Relative Numbers";
            }
            {
              key = "<leader>uc";
              mode = "n";
              silent = true;
              action = "<cmd>set cursorline!<CR>";
              desc = "Toggle Cursor Line";
            }
          ];
        };
      };
    };
  };
}
