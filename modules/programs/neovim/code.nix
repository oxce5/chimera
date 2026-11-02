# chimera.nvf.code — editing aids: mini ai/surround/pairs, autopairs, comments,
# guess-indent, ts-comments, dap.
{...}: {
  chimera.nvf.code = {
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      programs.nvf.settings.vim = {
        mini = {
          surround.enable = true;
          pairs = {
            enable = true;
            setupOpts = {
              modes = {
                insert = true;
                command = true;
                terminal = false;
              };
              skip_next = "[%w%%%'%[\"%.%`%\$]";
              skip_ts = ["string"];
              skip_unbalanced = true;
              markdown = true;
            };
          };
        };

        autopairs.nvim-autopairs.enable = true;
        comments.comment-nvim.enable = true;

        lazy.plugins."guess-indent.nvim" = {
          package = pkgs.vimPlugins.guess-indent-nvim;
          event = ["BufReadPost" "BufNewFile"];
          setupModule = "guess-indent";
          setupOpts = {};
        };

        lazy.plugins."ts-comments.nvim" = {
          package = pkgs.vimPlugins.ts-comments-nvim;
          event = ["BufReadPost" "BufNewFile"];
          setupModule = "ts-comments";
          setupOpts = {};
        };

        keymaps = [
          {
            key = "<leader>dc";
            mode = "n";
            silent = true;
            lua = true;
            action = "function() require('dap').continue() end";
            desc = "Continue/Start";
          }
          {
            key = "<leader>db";
            mode = "n";
            silent = true;
            lua = true;
            action = "function() require('dap').toggle_breakpoint() end";
            desc = "Toggle Breakpoint";
          }
          {
            key = "<leader>dB";
            mode = "n";
            silent = true;
            lua = true;
            action = "function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end";
            desc = "Breakpoint Condition";
          }
          {
            key = "<leader>dr";
            mode = "n";
            silent = true;
            lua = true;
            action = "function() require('dap').restart() end";
            desc = "Restart";
          }
          {
            key = "<leader>du";
            mode = "n";
            silent = true;
            lua = true;
            action = "function() require('dapui').toggle() end";
            desc = "Toggle DAP UI";
          }
          {
            key = "<leader>de";
            mode = "n";
            silent = true;
            lua = true;
            action = "function() require('dapui').eval() end";
            desc = "Evaluate";
          }
          {
            key = "<F5>";
            mode = "n";
            silent = true;
            lua = true;
            action = "function() require('dap').continue() end";
            desc = "Debug: Start/Continue";
          }
          {
            key = "<F1>";
            mode = "n";
            silent = true;
            lua = true;
            action = "function() require('dap').step_into() end";
            desc = "Debug: Step Into";
          }
          {
            key = "<F2>";
            mode = "n";
            silent = true;
            lua = true;
            action = "function() require('dap').step_over() end";
            desc = "Debug: Step Over";
          }
          {
            key = "<F3>";
            mode = "n";
            silent = true;
            lua = true;
            action = "function() require('dap').step_out() end";
            desc = "Debug: Step Out";
          }
          {
            key = "<F7>";
            mode = "n";
            silent = true;
            lua = true;
            action = "function() require('dapui').toggle() end";
            desc = "Debug: Toggle UI";
          }
        ];
      };
    };
  };
}
