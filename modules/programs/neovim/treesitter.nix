# chimera.nvf.treesitter — packaged (prebuilt) grammars, no runtime compilation.
{...}: {
  chimera.nvf.treesitter = {
    homeManager = {pkgs, ...}: {
      programs.nvf.settings.vim.treesitter = {
        enable = true;
        grammars = with pkgs.vimPlugins.nvim-treesitter.grammarPlugins; [
          bash
          c
          cpp
          go
          html
          java
          javascript
          json
          lua
          markdown
          nix
          python
          rust
          toml
          typescript
          vim
          vimdoc
          yaml
        ];
      };
    };
  };
}
