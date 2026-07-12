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

        plugins = [
          {
            name = "replay";
            src = pkgs.fetchFromGitHub {
              owner = "jorgebucaran";
              repo = "replay.fish";
              rev = "d2ecacd3fe7126e822ce8918389f3ad93b14c86c";
              hash = "sha256-TzQ97h9tBRUg+A7DSKeTBWLQuThicbu19DHMwkmUXdg=";
            };
          }
          {
            name = "pisces";
            src = pkgs.fishPlugins.pisces;
          }
          {
            name = "fzf";
            src = pkgs.fishPlugins.fzf-fish;
          }
          {
            name = "bass";
            src = pkgs.fishPlugins.bass;
          }
          {
            name = "done";
            src = pkgs.fishPlugins.done;
          }
          {
            name = "you-should-use";
            src = pkgs.fishPlugins.fish-you-should-use;
          }
          {
            name = "z";
            src = pkgs.fishPlugins.z;
          }
        ];
      };
    };
  };
}
