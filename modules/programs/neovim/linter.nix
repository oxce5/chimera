# chimera.nvf.lint lint/format plumbing and per-profile language wiring.
{
  chimera.nvf.lint = {
    homeManager = {lib, ...}: {
      programs.nvf.settings.vim = {
        formatter.conform-nvim = {
          enable = true;
          setupOpts = {
            default_format_opts = {
              timeout_ms = 5000;
              lsp_format = "fallback";
            };
            format_on_save = lib.generators.mkLuaInline ''
              function(bufnr)
                local enabled_filetypes = {
                  nix = true,
                  python = true,
                  java = true,
                }
                local ft = vim.bo[bufnr].filetype
                if enabled_filetypes[ft] then
                  return { timeout_ms = 5000, lsp_format = "fallback" }
                end
              end
            '';
          };
        };

        keymaps = [
          {
            key = "<leader>cf";
            mode = ["n" "v"];
            silent = true;
            lua = true;
            action = "function() require('conform').format { async = true } end";
            desc = "Format";
          }
        ];
      };
    };
  };

  chimera.nvf.lint.light = {
    homeManager = {pkgs, ...}: {
      programs.nvf.settings.vim = {
        # lint.light owns Python lint/format; prevent NVF's python language module
        # from injecting black (default format.type) or mypy (extraDiagnostics).
        languages.python = {
          format.enable = false;
          extraDiagnostics.enable = false;
        };

        extraPackages = [pkgs.ruff];

        diagnostics.nvim-lint.enable = true;
        diagnostics.nvim-lint.linters_by_ft = {
          python = ["ruff"];
          lua = ["selene"];
          sh = ["shellcheck"];
          bash = ["shellcheck"];
          fish = ["fish"];
        };

        formatter.conform-nvim.presets = {
          ruff.enable = true;
          ruff-fix.enable = true;
          ruff-organize-imports.enable = true;
        };
        formatter.conform-nvim.setupOpts.formatters_by_ft = {
          python = ["ruff-organize-imports" "ruff-fix" "ruff"];
        };

        keymaps = [
          {
            key = "<leader>cl";
            mode = "n";
            silent = true;
            lua = true;
            action = "function() require('lint').try_lint() end";
            desc = "Lint";
          }
        ];
      };
    };
  };

  chimera.nvf.lint.full = {
    homeManager = {
      programs.nvf.settings.vim = {
        diagnostics.nvim-lint.enable = true;
        diagnostics.nvim-lint.linters_by_ft = {
          nix = ["statix"];
          java = ["checkstyle"];
          c = ["clang_tidy"];
          cpp = ["clang_tidy"];
        };
        formatter.conform-nvim.setupOpts.formatters_by_ft = {
          nix = ["alejandra"];
          java = ["google-java-format"];
        };

        keymaps = [
          {
            key = "<leader>cl";
            mode = "n";
            silent = true;
            lua = true;
            action = "function() require('lint').try_lint() end";
            desc = "Lint";
          }
        ];
      };
    };
  };
}
