# chimera.nvf.code — editing aids: mini ai/surround/pairs, autopairs, comments.
{...}: {
  chimera.nvf.code = {
    homeManager = {...}: {
      programs.nvf.settings.vim = {
        mini = {
          ai.enable = true;
          surround.enable = true;
          pairs.enable = true;
        };

        autopairs.nvim-autopairs.enable = true;
        comments.comment-nvim.enable = true;
      };
    };
  };
}
