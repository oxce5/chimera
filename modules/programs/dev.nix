{
  chimera.dev = {
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
      programs.neovim = {
        enable = true;
        extraPackages = with pkgs; [
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
      # Allow imperative management of neovim luaconfig
      xdg.configFile."nvim/init.lua".enable = lib.mkForce false;
    };
    provides = {
      min = {
        homeManager = {pkgs, ...}: {
          home.packages = with pkgs; [
            devenv
          ];
        };
      };
    };
  };
}
