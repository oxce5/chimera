# chimera.nvf.nav — navigation: telescope, neo-tree, flash.
{...}: {
  chimera.nvf.nav = {
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      programs.nvf.settings.vim = {
        telescope.enable = true;
        telescope.extensions = [
          {
            name = "fzf";
            packages = [pkgs.vimPlugins.telescope-fzf-native-nvim];
            setup = {};
          }
          {
            name = "ui-select";
            packages = [];
            setup = lib.generators.mkLuaInline ''
              {
                ["ui-select"] = require('telescope.themes').get_dropdown()
              }
            '';
          }
        ];
        filetree.neo-tree.enable = true;
        filetree.neo-tree.setupOpts = {
          filesystem.window.mappings = {
            "\\" = "close_window";
          };
        };
        # flash moved from vim.motions to vim.utility.motion in this rev
        utility.motion.flash-nvim.enable = true;
        utility.motion.flash-nvim.mappings.toggle = "<c-s>";

        keymaps = [
          # NeoTree
          {
            key = "\\";
            mode = "n";
            silent = true;
            action = "<cmd>Neotree reveal<CR>";
            desc = "NeoTree Reveal";
          }
          {
            key = "<leader>e";
            mode = "n";
            silent = true;
            action = "<cmd>Neotree toggle<CR>";
            desc = "Toggle NeoTree";
          }
          {
            key = "<leader>E";
            mode = "n";
            silent = true;
            action = "<cmd>Neotree float<CR>";
            desc = "NeoTree Float";
          }
          {
            key = "<leader>gg";
            mode = "n";
            silent = true;
            action = "<cmd>Neotree float git_status<CR>";
            desc = "Git Status";
          }

          # Flash — treesitter incremental selection (custom actions)
          {
            key = "<c-space>";
            mode = ["n" "o" "x"];
            silent = true;
            lua = true;
            action = "function() require('flash').treesitter { actions = { ['<c-space>'] = 'next', ['<BS>'] = 'prev' } } end";
            desc = "Treesitter Incremental Selection";
          }

          # Trouble
          {
            key = "<leader>xx";
            mode = "n";
            silent = true;
            action = "<cmd>Trouble diagnostics toggle<CR>";
            desc = "Diagnostics (Trouble)";
          }
          {
            key = "<leader>xX";
            mode = "n";
            silent = true;
            action = "<cmd>Trouble diagnostics toggle filter.buf=0<CR>";
            desc = "Buffer Diagnostics (Trouble)";
          }
          {
            key = "<leader>cs";
            mode = "n";
            silent = true;
            action = "<cmd>Trouble symbols toggle<CR>";
            desc = "Symbols (Trouble)";
          }
          {
            key = "<leader>cS";
            mode = "n";
            silent = true;
            action = "<cmd>Trouble lsp toggle<CR>";
            desc = "LSP references/definitions/... (Trouble)";
          }
          {
            key = "<leader>xL";
            mode = "n";
            silent = true;
            action = "<cmd>Trouble loclist toggle<CR>";
            desc = "Location List (Trouble)";
          }
          {
            key = "<leader>xQ";
            mode = "n";
            silent = true;
            action = "<cmd>Trouble qflist toggle<CR>";
            desc = "Quickfix List (Trouble)";
          }
          {
            key = "[q";
            mode = "n";
            silent = true;
            lua = true;
            action = "function() if require('trouble').is_open() then require('trouble').prev { skip_groups = true, jump = true } else local ok, err = pcall(vim.cmd.cprev) if not ok then vim.notify(err, vim.log.levels.ERROR) end end end";
            desc = "Previous Trouble/Quickfix Item";
          }
          {
            key = "]q";
            mode = "n";
            silent = true;
            lua = true;
            action = "function() if require('trouble').is_open() then require('trouble').next { skip_groups = true, jump = true } else local ok, err = pcall(vim.cmd.cnext) if not ok then vim.notify(err, vim.log.levels.ERROR) end end end";
            desc = "Next Trouble/Quickfix Item";
          }

          # Telescope extras (nvf defaults cover <leader>ff/fg/fb/fh/fr)
          {
            key = "<leader>fn";
            mode = "n";
            silent = true;
            lua = true;
            action = "function() require('telescope.builtin').find_files { cwd = vim.fn.stdpath 'config', follow = true } end";
            desc = "Neovim Config Files";
          }
          {
            key = "<leader><leader>";
            mode = "n";
            silent = true;
            action = "<cmd>Telescope buffers<CR>";
            desc = "Find Buffers";
          }
          {
            key = "<leader>sw";
            mode = ["n" "v"];
            silent = true;
            lua = true;
            action = "function() require('telescope.builtin').grep_string() end";
            desc = "Search Word";
          }
          {
            key = "<leader>sd";
            mode = "n";
            silent = true;
            action = "<cmd>Telescope diagnostics<CR>";
            desc = "Search Diagnostics";
          }
          {
            key = "<leader>sR";
            mode = "n";
            silent = true;
            action = "<cmd>Telescope resume<CR>";
            desc = "Resume Search";
          }
          {
            key = "<leader>s.";
            mode = "n";
            silent = true;
            action = "<cmd>Telescope oldfiles<CR>";
            desc = "Recent Files";
          }
          {
            key = "<leader>s/";
            mode = "n";
            silent = true;
            lua = true;
            action = "function() require('telescope.builtin').live_grep { grep_open_files = true, prompt_title = 'Live Grep in Open Files' } end";
            desc = "Grep in Open Files";
          }
          {
            key = "<leader>sc";
            mode = "n";
            silent = true;
            action = "<cmd>Telescope commands<CR>";
            desc = "Commands";
          }
          {
            key = "<leader>sk";
            mode = "n";
            silent = true;
            action = "<cmd>Telescope keymaps<CR>";
            desc = "Keymaps";
          }
          {
            key = "<leader>/";
            mode = "n";
            silent = true;
            lua = true;
            action = "function() require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown { winblend = 10, previewer = false }) end";
            desc = "Search in Buffer";
          }

          # Git telescope keymaps (original <leader>g* prefix)
          {
            key = "<leader>gc";
            mode = "n";
            silent = true;
            action = "<cmd>Telescope git_commits<CR>";
            desc = "Git Commits";
          }
          {
            key = "<leader>gb";
            mode = "n";
            silent = true;
            action = "<cmd>Telescope git_branches<CR>";
            desc = "Git Branches";
          }
          {
            key = "<leader>gf";
            mode = "n";
            silent = true;
            action = "<cmd>Telescope git_files<CR>";
            desc = "Git Files";
          }
          {
            key = "<leader>gs";
            mode = "n";
            silent = true;
            action = "<cmd>Telescope git_status<CR>";
            desc = "Git Status";
          }
        ];
      };
    };
  };
}
