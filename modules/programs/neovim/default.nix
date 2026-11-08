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
            updatetime = 200;
            timeoutlen = 300;
            ignorecase = true;
            smartcase = true;
            splitright = true;
            splitbelow = true;
            list = true;
            listchars = {
              tab = "│ ";
              trail = "·";
              nbsp = "␣";
            };
            inccommand = "nosplit";
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

          augroups = [
            {
              name = "highlight-yank";
              clear = true;
            }
            {
              name = "checktime";
              clear = true;
            }
            {
              name = "last-loc";
              clear = true;
            }
            {
              name = "close-with-q";
              clear = true;
            }
            {
              name = "auto-create-dir";
              clear = true;
            }
          ];

          autocmds = [
            {
              event = ["TextYankPost"];
              pattern = ["*"];
              group = "highlight-yank";
              desc = "Highlight on yank";
              callback = lib.generators.mkLuaInline "function() vim.hl.on_yank() end";
            }
            {
              event = ["FocusGained" "TermClose" "TermLeave"];
              pattern = ["*"];
              group = "checktime";
              desc = "Check if file changed outside vim";
              callback = lib.generators.mkLuaInline "function() if vim.o.buftype ~= 'nofile' then vim.cmd('checktime') end end";
            }
            {
              event = ["BufReadPost"];
              pattern = ["*"];
              group = "last-loc";
              desc = "Restore last cursor position";
              callback = lib.generators.mkLuaInline ''
                function(event)
                  local exclude = { "gitcommit", "commit" }
                  local buf = event.buf
                  if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].last_loc then return end
                  vim.b[buf].last_loc = true
                  local mark = vim.api.nvim_buf_get_mark(buf, '"')
                  local lcount = vim.api.nvim_buf_line_count(buf)
                  if mark[1] > 0 and mark[1] <= lcount then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
                end
              '';
            }
            {
              event = ["FileType"];
              pattern = [
                "help"
                "lspinfo"
                "notify"
                "qf"
                "checkhealth"
                "gitsigns-blame"
                "grug-far"
                "startuptime"
              ];
              group = "close-with-q";
              desc = "Close with q";
              callback = lib.generators.mkLuaInline ''
                function(event)
                  vim.bo[event.buf].buflisted = false
                  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
                end
              '';
            }
            {
              event = ["BufWritePre"];
              pattern = ["*"];
              group = "auto-create-dir";
              desc = "Auto-create parent directories on save";
              callback = lib.generators.mkLuaInline ''
                function(event)
                  if event.match:match("^%w%w+:[\\/][\\/]") then return end
                  local file = vim.uv.fs_realpath(event.match) or event.match
                  vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
                end
              '';
            }
          ];

          # LazyVim-feel core keymaps, kept modular/minimal. No window splits (Herdr).
          keymaps = [
            # better up/down
            {
              key = "j";
              mode = ["n" "x"];
              expr = true;
              silent = true;
              action = "v:count == 0 ? 'gj' : 'j'";
              desc = "Down";
            }
            {
              key = "k";
              mode = ["n" "x"];
              expr = true;
              silent = true;
              action = "v:count == 0 ? 'gk' : 'k'";
              desc = "Up";
            }
            {
              key = "<Down>";
              mode = ["n" "x"];
              expr = true;
              silent = true;
              action = "v:count == 0 ? 'gj' : 'j'";
              desc = "Down";
            }
            {
              key = "<Up>";
              mode = ["n" "x"];
              expr = true;
              silent = true;
              action = "v:count == 0 ? 'gk' : 'k'";
              desc = "Up";
            }

            # window navigation (no split management; Herdr handles multiplexing)
            {
              key = "<C-h>";
              mode = "n";
              silent = true;
              action = "<C-w>h";
              desc = "Go to Left Window";
            }
            {
              key = "<C-j>";
              mode = "n";
              silent = true;
              action = "<C-w>j";
              desc = "Go to Lower Window";
            }
            {
              key = "<C-k>";
              mode = "n";
              silent = true;
              action = "<C-w>k";
              desc = "Go to Upper Window";
            }
            {
              key = "<C-l>";
              mode = "n";
              silent = true;
              action = "<C-w>l";
              desc = "Go to Right Window";
            }

            # buffers
            {
              key = "<S-h>";
              mode = "n";
              silent = true;
              action = "<cmd>bprevious<CR>";
              desc = "Prev Buffer";
            }
            {
              key = "<S-l>";
              mode = "n";
              silent = true;
              action = "<cmd>bnext<CR>";
              desc = "Next Buffer";
            }
            {
              key = "[b";
              mode = "n";
              silent = true;
              action = "<cmd>bprevious<CR>";
              desc = "Prev Buffer";
            }
            {
              key = "]b";
              mode = "n";
              silent = true;
              action = "<cmd>bnext<CR>";
              desc = "Next Buffer";
            }
            {
              key = "<leader>bb";
              mode = "n";
              silent = true;
              action = "<cmd>e #<CR>";
              desc = "Switch to Other Buffer";
            }
            {
              key = "<leader>`";
              mode = "n";
              silent = true;
              action = "<cmd>e #<CR>";
              desc = "Switch to Other Buffer";
            }
            {
              key = "<leader>bd";
              mode = "n";
              silent = true;
              action = "<cmd>bdelete<CR>";
              desc = "Delete Buffer";
            }
            {
              key = "<leader>bo";
              mode = "n";
              silent = true;
              lua = true;
              action = "function() local cur = vim.api.nvim_get_current_buf(); for _, b in ipairs(vim.api.nvim_list_bufs()) do if b ~= cur and vim.bo[b].buflisted and vim.bo[b].buftype == '' then pcall(vim.api.nvim_buf_delete, b, {}) end end end";
              desc = "Delete Other Buffers";
            }
            {
              key = "<leader>bD";
              mode = "n";
              silent = true;
              action = "<cmd>bd<CR>";
              desc = "Delete Buffer and Window";
            }

            # clear search
            {
              key = "<Esc>";
              mode = ["i" "n" "s"];
              silent = true;
              action = "<cmd>noh<CR><Esc>";
              desc = "Escape and Clear hlsearch";
            }
            {
              key = "<leader>ur";
              mode = "n";
              silent = true;
              action = "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>";
              desc = "Redraw / Clear hlsearch / Diff Update";
            }

            # better search
            {
              key = "n";
              mode = "n";
              expr = true;
              silent = true;
              action = "'Nn'[v:searchforward].'zv'";
              desc = "Next Search Result";
            }
            {
              key = "n";
              mode = ["x" "o"];
              expr = true;
              silent = true;
              action = "'Nn'[v:searchforward]";
              desc = "Next Search Result";
            }
            {
              key = "N";
              mode = "n";
              expr = true;
              silent = true;
              action = "'nN'[v:searchforward].'zv'";
              desc = "Prev Search Result";
            }
            {
              key = "N";
              mode = ["x" "o"];
              expr = true;
              silent = true;
              action = "'nN'[v:searchforward]";
              desc = "Prev Search Result";
            }

            # undo break-points
            {
              key = ",";
              mode = "i";
              action = ",<c-g>u";
            }
            {
              key = ".";
              mode = "i";
              action = ".<c-g>u";
            }
            {
              key = ";";
              mode = "i";
              action = ";<c-g>u";
            }

            # save
            {
              key = "<C-s>";
              mode = ["i" "x" "n" "s"];
              silent = true;
              action = "<cmd>w<CR><esc>";
              desc = "Save File";
            }

            # better indenting
            {
              key = "<";
              mode = "x";
              action = "<gv";
            }
            {
              key = ">";
              mode = "x";
              action = ">gv";
            }

            # new file / quit
            {
              key = "<leader>fn";
              mode = "n";
              silent = true;
              action = "<cmd>enew<CR>";
              desc = "New File";
            }
            {
              key = "<leader>qq";
              mode = "n";
              silent = true;
              action = "<cmd>qa<CR>";
              desc = "Quit All";
            }

            # diagnostics (LazyVim feel; LSP float mapping lives in lsp/default.nix)
            {
              key = "[d";
              mode = "n";
              silent = true;
              lua = true;
              action = "function() vim.diagnostic.jump({ count = -vim.v.count1, float = true }) end";
              desc = "Prev Diagnostic";
            }
            {
              key = "]d";
              mode = "n";
              silent = true;
              lua = true;
              action = "function() vim.diagnostic.jump({ count = vim.v.count1, float = true }) end";
              desc = "Next Diagnostic";
            }
            {
              key = "[e";
              mode = "n";
              silent = true;
              lua = true;
              action = "function() vim.diagnostic.jump({ count = -vim.v.count1, severity = vim.diagnostic.severity.ERROR, float = true }) end";
              desc = "Prev Error";
            }
            {
              key = "]e";
              mode = "n";
              silent = true;
              lua = true;
              action = "function() vim.diagnostic.jump({ count = vim.v.count1, severity = vim.diagnostic.severity.ERROR, float = true }) end";
              desc = "Next Error";
            }
            {
              key = "[w";
              mode = "n";
              silent = true;
              lua = true;
              action = "function() vim.diagnostic.jump({ count = -vim.v.count1, severity = vim.diagnostic.severity.WARN, float = true }) end";
              desc = "Prev Warning";
            }
            {
              key = "]w";
              mode = "n";
              silent = true;
              lua = true;
              action = "function() vim.diagnostic.jump({ count = vim.v.count1, severity = vim.diagnostic.severity.WARN, float = true }) end";
              desc = "Next Warning";
            }
            {
              key = "<leader>xd";
              mode = "n";
              silent = true;
              lua = true;
              action = "vim.diagnostic.setloclist";
              desc = "Diagnostics (Loclist)";
            }
            {
              key = "<leader>xl";
              mode = "n";
              silent = true;
              lua = true;
              action = "function() local win = vim.fn.getloclist(0, { winid = 0 }).winid; if win ~= 0 then vim.cmd.lclose() else vim.cmd.lopen() end end";
              desc = "Location List";
            }
            {
              key = "<leader>xq";
              mode = "n";
              silent = true;
              lua = true;
              action = "function() local win = vim.fn.getqflist({ winid = 0 }).winid; if win ~= 0 then vim.cmd.cclose() else vim.cmd.copen() end end";
              desc = "Quickfix List";
            }

            # ui toggles (LazyVim feel)
            {
              key = "<leader>ul";
              mode = "n";
              silent = true;
              action = "<cmd>set number!<CR>";
              desc = "Toggle Line Numbers";
            }
            {
              key = "<leader>uL";
              mode = "n";
              silent = true;
              action = "<cmd>set relativenumber!<CR>";
              desc = "Toggle Relative Numbers";
            }
            {
              key = "<leader>uw";
              mode = "n";
              silent = true;
              action = "<cmd>set wrap!<CR>";
              desc = "Toggle Wrap";
            }
            {
              key = "<leader>us";
              mode = "n";
              silent = true;
              action = "<cmd>set spell!<CR>";
              desc = "Toggle Spelling";
            }
            {
              key = "<leader>uh";
              mode = "n";
              silent = true;
              action = "<cmd>nohlsearch<CR>";
              desc = "Clear Highlights";
            }

            # terminal (no splits; simple escape)
            {
              key = "<Esc><Esc>";
              mode = "t";
              silent = true;
              action = "<C-\\><C-n>";
              desc = "Exit Terminal Mode";
            }
          ];
        };
      };
    };
  };
}
