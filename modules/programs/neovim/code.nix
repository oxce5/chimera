# chimera.nvf.code — editing aids: mini ai/surround/pairs, autopairs, comments,
# guess-indent, ts-comments.
{...}: {
  chimera.nvf.code = {
    homeManager = {pkgs, ...}: {
      programs.nvf.settings.vim = {
        mini = {
          ai.enable = true;
          surround.enable = true;
          pairs.enable = true;
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
      };
    };
  };
}
