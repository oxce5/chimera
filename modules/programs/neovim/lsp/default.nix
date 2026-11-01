# chimera.nvf.lsp — shared LSP plumbing: completion, snippets, format/lint
# plugins, LSP keymaps. Language sets split into ./light.nix and ./full.nix.
{...}: {
  chimera.nvf.lsp = {
    homeManager = {...}: {
      programs.nvf.settings.vim = {
        lsp = {
          enable = true;
          formatOnSave = false;
          trouble.enable = true;
        };

        autocomplete = {
          enableSharedCmpSources = true;
          blink-cmp = {
            enable = true;
            friendly-snippets.enable = true;
          };
        };

        snippets = {
          luasnip.enable = true;
        };

        # Language plumbing shared by every enabled language below/above.
        # (No global enableLSP in this rev — languages.<x>.enable implies its LSP.)
        languages = {
          enableFormat = true;
          enableTreesitter = true;
          enableExtraDiagnostics = true;
        };

        diagnostics.nvim-lint.enable = true;
        formatter.conform-nvim.enable = true;

        keymaps = [
          {
            key = "<leader>ca";
            mode = ["n" "x"];
            silent = true;
            action = "vim.lsp.buf.code_action";
            desc = "Code Action";
          }
          {
            key = "<leader>cr";
            mode = "n";
            silent = true;
            action = "vim.lsp.buf.rename";
            desc = "Rename";
          }
          {
            key = "<leader>cd";
            mode = "n";
            silent = true;
            action = "vim.diagnostic.open_float";
            desc = "Line Diagnostics";
          }
          {
            key = "<leader>ci";
            mode = "n";
            silent = true;
            action = "<cmd>LspInfo<CR>";
            desc = "LSP Info";
          }
          {
            key = "<leader>cL";
            mode = "n";
            silent = true;
            action = "<cmd>LspLog<CR>";
            desc = "LSP Log";
          }

          {
            key = "gd";
            mode = "n";
            silent = true;
            action = "vim.lsp.buf.definition";
            desc = "Goto Definition";
          }
          {
            key = "gr";
            mode = "n";
            nowait = true;
            action = "vim.lsp.buf.references";
            desc = "References";
          }
          {
            key = "gI";
            mode = "n";
            silent = true;
            action = "vim.lsp.buf.implementation";
            desc = "Goto Implementation";
          }
          {
            key = "gy";
            mode = "n";
            silent = true;
            action = "vim.lsp.buf.type_definition";
            desc = "Goto Type Definition";
          }
          {
            key = "gD";
            mode = "n";
            silent = true;
            action = "vim.lsp.buf.declaration";
            desc = "Goto Declaration";
          }
          {
            key = "K";
            mode = "n";
            silent = true;
            action = "vim.lsp.buf.hover";
            desc = "Hover";
          }
          {
            key = "gK";
            mode = "n";
            silent = true;
            action = "vim.lsp.buf.signature_help";
            desc = "Signature Help";
          }
          {
            key = "<c-k>";
            mode = "i";
            silent = true;
            action = "vim.lsp.buf.signature_help";
            desc = "Signature Help";
          }
        ];

        # Buffer-local maps on LspAttach; telescope is in chimera.nvf.nav,
        # which both profiles include alongside this aspect.
        luaConfigRC = {
          lsp-attach = ''
            local builtin = require('telescope.builtin')
            local map = vim.keymap.set
            vim.api.nvim_create_autocmd('LspAttach', {
              group = vim.api.nvim_create_augroup('lsp-attach-keymaps', { clear = true }),
              callback = function(event)
                local buf = event.buf
                local opts = { buffer = buf, silent = true }
                map('n', 'grr', builtin.lsp_references, vim.tbl_extend('force', opts, { desc = 'Goto References' }))
                map('n', 'gri', builtin.lsp_implementations, vim.tbl_extend('force', opts, { desc = 'Goto Implementation' }))
                map('n', 'grd', builtin.lsp_definitions, vim.tbl_extend('force', opts, { desc = 'Goto Definition' }))
                map('n', 'gO', builtin.lsp_document_symbols, vim.tbl_extend('force', opts, { desc = 'Document Symbols' }))
                map('n', 'gW', builtin.lsp_dynamic_workspace_symbols, vim.tbl_extend('force', opts, { desc = 'Workspace Symbols' }))
                map('n', 'grt', builtin.lsp_type_definitions, vim.tbl_extend('force', opts, { desc = 'Goto Type Definition' }))
              end,
            })
          '';
        };
      };
    };
  };
}
