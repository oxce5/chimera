{chimera, ...}: {
  chimera.neovim = {
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
      programs.neovim.enable = true;
      # Allow imperative management of neovim luaconfig
      xdg.configFile."nvim/init.lua".enable = lib.mkForce false;

      home.packages = with pkgs; [
        # DO NOT REMOVE: Treesitter requirement
        gcc
      ];
    };

    lsp = {
      common.homeManager = {pkgs, ...}: {
        programs.neovim.extraPackages = with pkgs; [
          tree-sitter
          bash-language-server
          yaml-language-server
          basedpyright
          clang-tools
        ];
      };
      nix.homeManager = {pkgs, ...}: {
        programs.neovim.extraPackages = with pkgs; [
          nil
          nixd
        ];
      };
      general.homeManager = {pkgs, ...}: {
        programs.neovim.extraPackages = with pkgs; [
          dockerfile-language-server
          jdt-language-server
          lua-language-server
        ];
      };
    };

    lint = {
      common.homeManager = {pkgs, ...}: {
        programs.neovim.extraPackages = [pkgs.ruff];
      };
      nix.homeManager = {pkgs, ...}: {
        programs.neovim.extraPackages = [pkgs.alejandra];
      };
      general.homeManager = {pkgs, ...}: {
        programs.neovim.extraPackages = with pkgs; [
          checkstyle
          stylua
          selene
        ];
      };
    };
  };
}
