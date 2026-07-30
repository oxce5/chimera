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
      };
    };
    baseWithLsp = {
      homeManager = {pkgs, ...}: {
        programs.neovim.extraPackages = with pkgs; [
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
      includes = [chimera.dev._.base];
      homeManager = {pkgs, ...}: {
        home.packages = with pkgs; [
          devenv
          opencode
        ];
      };
    };
  };
}
