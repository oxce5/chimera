{chimera, ...}: {
  chimera.neovim.provides = {
    base = {
      nixos = {
        programs.neovim = {
          enable = true;
          defaultEditor = true;
        };
      };
      homeManager = {
        lib,
        pkgs,
        ...
      }: {
        programs = {
          neovim.enable = true;
        };
        # Allow imperative management of neovim luaconfig
        xdg.configFile."nvim/init.lua".enable = lib.mkForce false;

        home.packages = with pkgs; [
          # DO NOT REMOVE: Treesitter requirement
          gcc
        ];
      };
    };
    lsp = {
      homeManager = {pkgs, ...}: {
        programs.neovim.extraPackages = with pkgs; [
          tree-sitter
          bash-language-server
          yaml-language-server
          basedpyright
          clang-tools
        ];
      };
    };
    nix-lsp = {
      homeManager = {pkgs, ...}: {
        programs.neovim.extraPackages = with pkgs; [
          nil
          nixd
          alejandra
        ];
      };
    };
    linters.homeManager = {pkgs, ...}: {
      programs.neovim.extraPackages = with pkgs; [
        ruff
        checkstyle
        clang-tools
        selene
      ];
    };
    general-lsp.homeManager = {pkgs, ...}: {
      programs.neovim.extraPackages = with pkgs; [
        dockerfile-language-server
        jdt-language-server
        lua-language-server
        stylua
      ];
    };
    baseWithLsp = {
      includes = [
        chimera.neovim._.base
        chimera.neovim._.lsp
        chimera.neovim._.nix-lsp
        chimera.neovim._.linters
        chimera.neovim._.general-lsp
      ];
    };
  };
}
