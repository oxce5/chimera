{chimera, ...}: {
  chimera.dev.provides = {
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
          uv.enable = true;
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
    general-lsp.homeManager = { pkgs, ... }: {
      programs.neovim.extraPackages = with pkgs; [
        dockerfile-language-server
        jdt-language-server
        lua-language-server
        stylua
      ];
    };
    baseWithLsp = {
      includes = [
        chimera.dev._.base
        chimera.dev._.lsp
        chimera.dev._.nix-lsp
        chimera.dev._.general-lsp
      ];
    };
    min = {
      includes = [chimera.dev._.baseWithLsp];
      homeManager = {pkgs, ...}: {
        home.packages = with pkgs; [
          devenv
        ];
      };
    };
    ai = {
      includes = [chimera.dev._.sessions];
      homeManager = {
        programs.opencode = {
          enable = true;
        };
      };
    };
    sessions = {
      homeManager = {
        programs.herdr.enable = true;
      };
    };
  };
}
