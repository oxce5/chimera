# chimera.nvf.nav — navigation: telescope, neo-tree, flash.
{...}: {
  chimera.nvf.nav = {
    homeManager = {lib, ...}: {
      programs.nvf.settings.vim = {
        telescope.enable = true;
        filetree.neo-tree.enable = true;
        # flash moved from vim.motions to vim.utility.motion in this rev
        utility.motion.flash-nvim.enable = true;

        keymaps = [
          {
            key = "<leader>gg";
            mode = "n";
            silent = true;
            action = "<cmd>Neotree float git_status<CR>";
            desc = "Git Status";
          }
        ];
      };
    };
  };
}
