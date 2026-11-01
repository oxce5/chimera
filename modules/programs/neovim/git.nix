# chimera.nvf.git — gitsigns + the <leader>gh* / toggle keymaps.
{...}: {
  chimera.nvf.git = {
    homeManager = {...}: {
      programs.nvf.settings.vim = {
        git = {
          enable = true;
          gitsigns.enable = true;
        };

        keymaps = [
          {
            key = "<leader>ghs";
            mode = ["n" "v"];
            silent = true;
            action = "<cmd>Gitsigns stage_hunk<CR>";
            desc = "Stage Hunk";
          }
          {
            key = "<leader>ghr";
            mode = ["n" "v"];
            silent = true;
            action = "<cmd>Gitsigns reset_hunk<CR>";
            desc = "Reset Hunk";
          }
          {
            key = "<leader>ghS";
            mode = "n";
            silent = true;
            action = "<cmd>Gitsigns stage_buffer<CR>";
            desc = "Stage Buffer";
          }
          {
            key = "<leader>ghu";
            mode = "n";
            silent = true;
            action = "<cmd>Gitsigns undo_stage_hunk<CR>";
            desc = "Undo Stage Hunk";
          }
          {
            key = "<leader>ghR";
            mode = "n";
            silent = true;
            action = "<cmd>Gitsigns reset_buffer<CR>";
            desc = "Reset Buffer";
          }
          {
            key = "<leader>ghp";
            mode = "n";
            silent = true;
            action = "<cmd>Gitsigns preview_hunk<CR>";
            desc = "Preview Hunk";
          }
          {
            key = "<leader>ghi";
            mode = "n";
            silent = true;
            action = "<cmd>Gitsigns preview_hunk_inline<CR>";
            desc = "Preview Hunk Inline";
          }
          {
            key = "<leader>ghb";
            mode = "n";
            silent = true;
            lua = true;
            action = "function() require('gitsigns').blame_line { full = true } end";
            desc = "Blame Line";
          }
          {
            key = "<leader>ghB";
            mode = "n";
            silent = true;
            action = "<cmd>Gitsigns blame<CR>";
            desc = "Blame Buffer";
          }
          {
            key = "<leader>ghd";
            mode = "n";
            silent = true;
            action = "<cmd>Gitsigns diffthis<CR>";
            desc = "Diff Against Index";
          }
          {
            key = "<leader>ghD";
            mode = "n";
            silent = true;
            lua = true;
            action = "function() require('gitsigns').diffthis '~' end";
            desc = "Diff Against Last Commit";
          }
          {
            key = "<leader>tb";
            mode = "n";
            silent = true;
            action = "<cmd>Gitsigns toggle_current_line_blame<CR>";
            desc = "Toggle Git Blame Line";
          }
          {
            key = "<leader>tw";
            mode = "n";
            silent = true;
            action = "<cmd>Gitsigns toggle_word_diff<CR>";
            desc = "Toggle Word Diff";
          }
          {
            key = "<leader>uG";
            mode = "n";
            silent = true;
            lua = true;
            action = "function() require('gitsigns').toggle_signs() end";
            desc = "Toggle Git Signs";
          }
        ];
      };
    };
  };
}
