{
  chimera.fish = {user, ...}: {
    nixos = {pkgs, ...}: {
      programs.fish.enable = true;
    };
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs.fishPlugins; [
        colored-man-pages
        done
        foreign-env
        pkgs.libnotify # notify-send for done
      ];
      programs.fish = {
        enable = true;

        shellAliases = {
          aj = "alejandra ~/.flake";
          ls = "eza";
          ll = "eza -la";
          lt = "eza -Ta";
          bssh = "ssh -t administrator@bastion --";
        };
        shellAbbrs = {
          gs = "git status";
          cd = "z";
          df = "duf";
          ga = "git add";
          lg = "lazygit";
          ld = "lazydocker";
        };

        interactiveShellInit = ''
          set fish_greeting
        '';

        plugins = let
          mkPlugin = name: src: {inherit name src;};
        in [
          {
            name = "replay";
            src = pkgs.fetchFromGitHub {
              owner = "jorgebucaran";
              repo = "replay.fish";
              rev = "d2ecacd3fe7126e822ce8918389f3ad93b14c86c";
              hash = "sha256-TzQ97h9tBRUg+A7DSKeTBWLQuThicbu19DHMwkmUXdg=";
            };
          }
          (mkPlugin "pisces" pkgs.fishPlugins.pisces)
          (mkPlugin "fzf" pkgs.fishPlugins.fzf-fish)
          (mkPlugin "bass" pkgs.fishPlugins.bass)
          (mkPlugin "done" pkgs.fishPlugins.done)
          (mkPlugin "you-should-use" pkgs.fishPlugins.fish-you-should-use)
          (mkPlugin "z" pkgs.fishPlugins.z)
        ];
      };
    };
  };
}
