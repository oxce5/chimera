# chimera.nvf.treesitter declarative packaged grammars.
{...}: {
  chimera.nvf.treesitter = {
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      programs.nvf.settings.vim = {
        treesitter.enable = true;
        treesitter.grammars = with pkgs.vimPlugins.nvim-treesitter.grammarPlugins; [
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
