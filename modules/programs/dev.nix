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
        programs.neovim.enable = true;
        # Allow imperative management of neovim luaconfig
        xdg.configFile."nvim/init.lua".enable = lib.mkForce false;

        home.packages = with pkgs; [
          gcc
        ];
      };
    };
    baseWithLsp = {
      includes = [chimera.dev._.base];
      homeManager = {pkgs, ...}: {
        programs.neovim.extraPackages = with pkgs; [
          tree-sitter

          bash-language-server
          dockerfile-language-server
          yaml-language-server
          jdt-language-server
          basedpyright
          nil
          clang-tools
          lua-language-server
          stylua
          alejandra
        ];
      };
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
      homeManager = {pkgs, ...}: {
        programs.herdr.enable = true;

        home.packages = with pkgs; [
          opencode
        ];
      };
    };
  };
}
