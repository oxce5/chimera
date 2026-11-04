# chimera.nvf.ui.todo-comments highlight TODO/FIXME/etc in comments
{...}: {
  chimera.nvf.ui = {
    homeManager = {...}: {
      programs.nvf.settings.vim.notes.todo-comments = {
        enable = true;
        setupOpts.signs = false;
      };
    };
  };
}
