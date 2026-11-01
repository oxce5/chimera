# chimera.nvf.ui.todo-comments — highlight TODO/FIXME/etc in comments.
{...}: {
  chimera.nvf.ui = {
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      programs.nvf.settings.vim.lazy.plugins."todo-comments.nvim" = {
        package = pkgs.vimPlugins.todo-comments-nvim;
        event = ["BufReadPost" "BufNewFile"];
        setupModule = "todo-comments";
        setupOpts = {
          signs = false;
        };
      };
    };
  };
}
