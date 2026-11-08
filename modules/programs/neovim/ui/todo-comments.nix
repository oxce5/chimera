# chimera.nvf.ui.todo-comments highlight TODO/FIXME/etc in comments
{...}: {
  chimera.nvf.ui = {
    homeManager = {...}: {
      programs.nvf.settings.vim = {
        notes.todo-comments = {
          enable = true;
          setupOpts.signs = false;
          mappings = {
            telescope = "<leader>st";
            trouble = "<leader>xt";
            quickFix = null;
          };
        };

        keymaps = [
          {
            key = "]t";
            mode = "n";
            silent = true;
            lua = true;
            action = "function() require('todo-comments').jump_next() end";
            desc = "Next Todo Comment";
          }
          {
            key = "[t";
            mode = "n";
            silent = true;
            lua = true;
            action = "function() require('todo-comments').jump_prev() end";
            desc = "Previous Todo Comment";
          }
          {
            key = "<leader>xT";
            mode = "n";
            silent = true;
            action = "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<CR>";
            desc = "Todo/Fix/Fixme (Telescope)";
          }
        ];
      };
    };
  };
}
