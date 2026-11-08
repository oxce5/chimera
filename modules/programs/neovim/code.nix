# chimera.nvf.code editing aids: mini ai/surround/pairs, guess-indent,
# ts-comments, NVF-managed debugger wiring.
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

        utility.guess-indent-nvim = {
          enable = true;
          setupOpts.on_tab_options = {};
        };

        lazy.plugins."ts-comments.nvim" = {
          package = pkgs.vimPlugins.ts-comments-nvim;
          event = ["BufReadPost" "BufNewFile"];
          setupModule = "ts-comments";
          setupOpts = {};
        };

        debugger.nvim-dap = {
          enable = true;
          ui = {
            enable = true;
            autoStart = true;
            setupOpts = {
              icons = {
                expanded = "▾";
                collapsed = "▸";
                current_frame = "*";
              };
              controls.icons = {
                pause = "⏸";
                play = "▶";
                step_into = "⏎";
                step_over = "⏭";
                step_out = "⏮";
                step_back = "b";
                run_last = "▶▶";
                terminate = "⏹";
                disconnect = "⏏";
              };
            };
          };
          mappings = {
            continue = "<leader>dc";
            restart = "<leader>dr";
            terminate = "<leader>dq";
            runLast = "<leader>d.";
            toggleRepl = "<leader>dQ";
            hover = "<leader>dh";
            toggleBreakpoint = "<leader>db";
            runToCursor = "<leader>dgc";
            stepInto = "<F1>";
            stepOver = "<F2>";
            stepOut = "<F3>";
            stepBack = "<leader>dgk";
            goUp = "<leader>dvo";
            goDown = "<leader>dvi";
            toggleDapUI = "<leader>du";
          };
        };

        # debug actions NVF's nvim-dap.mappings does not cover.
        keymaps = [
          {
            key = "<leader>dB";
            mode = "n";
            silent = true;
            lua = true;
            action = "function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end";
            desc = "Breakpoint Condition";
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
