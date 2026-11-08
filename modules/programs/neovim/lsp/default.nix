# chimera.nvf.lsp shared LSP plumbing: completion, snippets, UI, R.nvim,
# LSP keymaps. Language LSPs split into ./light.nix and ./full.nix
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
          lspsaga = {
            enable = true;
            setupOpts.code_action.keys.quit = ["q" "<Esc>"];
          };
          lightbulb.enable = true;

          mappings = {
            renameSymbol = "<leader>cr";
            openDiagnosticFloat = "<leader>cd";
            goToDefinition = "gd";
            listImplementations = "gI";
            goToType = "gy";
            goToDeclaration = "gD";
            hover = "K";
            signatureHelp = "gK";
          };
        };

        autocomplete = {
          enableSharedCmpSources = true;
          blink-cmp = {
            enable = true;
            friendly-snippets.enable = true;
          };
        };

        snippets.luasnip.enable = true;

        # enable essentials for every enabled lang
        languages = {
          enableFormat = true;
          enableTreesitter = true;
          enableExtraDiagnostics = true;
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
            action = "<cmd>Lspsaga code_action<CR>";
            desc = "Code Action";
          }
          {
            key = "gr";
            mode = "n";
            silent = true;
            nowait = true;
            lua = true;
            action = "vim.lsp.buf.references";
            desc = "References";
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
            key = "<c-k>";
            mode = "i";
            silent = true;
            lua = true;
            action = "vim.lsp.buf.signature_help";
            desc = "Signature Help";
          }
        ];

        augroups = [
          {
            name = "lsp-inlay-hints";
            clear = true;
          }
        ];

        autocmds = [
          {
            event = ["LspAttach"];
            group = "lsp-inlay-hints";
            desc = "Always enable inlay hints";
            callback = lib.generators.mkLuaInline ''
              function(event)
                local client = vim.lsp.get_client_by_id(event.data.client_id)
                if client and client:supports_method("textDocument/inlayHint", { bufnr = event.buf }) then
                  vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
                end
              end
            '';
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
