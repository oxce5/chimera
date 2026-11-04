# chimera.nvf.lsp shared LSP plumbing: completion, snippets, format/lint,
# R.nvim, LSP keymaps. language sets split into ./light.nix and ./full.nix.
{...}: {
  chimera.nvf.lsp = {
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
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

        # enable essentials for every enabled lang
        languages = {
          enableFormat = true;
          enableTreesitter = true;
          enableExtraDiagnostics = true;
        };

        diagnostics.nvim-lint.enable = true;
        diagnostics.nvim-lint.linters_by_ft = {
          python = ["ruff"];
          java = ["checkstyle"];
          nix = ["statix"];
          c = ["clang_tidy"];
          cpp = ["clang_tidy"];
          lua = ["selene"];
          sh = ["shellcheck"];
          bash = ["shellcheck"];
          fish = ["fish"];
        };

        formatter.conform-nvim.enable = true;
        formatter.conform-nvim.setupOpts = {
          format_on_save = lib.generators.mkLuaInline ''
            function(bufnr)
              local enabled_filetypes = {
                nix = true,
                java = true,
              }
              if enabled_filetypes[vim.bo[bufnr].filetype] then
                return { timeout_ms = 500 }
              else
                return nil
              end
            end
          '';
          formatters_by_ft = {
            nix = ["alejandra"];
            java = ["google-java-format"];
          };
        };

        lazy.plugins."R.nvim" = {
          package = pkgs.vimPlugins.R-nvim;
          ft = ["r" "rmd" "quarto"];
        };

        # fidget.nvim — LSP status updates
        visuals.fidget-nvim.enable = true;

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
            key = "<leader>cf";
            mode = ["n" "v"];
            silent = true;
            lua = true;
            action = "function() require('conform').format { async = true } end";
            desc = "Format Buffer";
          }
          {
            key = "<leader>cl";
            mode = "n";
            silent = true;
            lua = true;
            action = "function() require('lint').try_lint() end";
            desc = "Lint Buffer";
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
            silent = true;
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
          lsp-attach = {
            data = builtins.readFile ./lsp-attach.lua;
            before = [];
            after = ["pluginConfigs"];
          };
        };
      };
    };
  };
}
