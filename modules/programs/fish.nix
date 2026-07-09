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
          aj = "alejandra ~/nix-setup";
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
      };
    };
  };
}
# {
#   unify = {
#     nixos.programs.fish.enable = true;
#     home = {
#       pkgs,
#       lib,
#       ...
#     }: {
#       home.packages = with pkgs.fishPlugins; [
#         colored-man-pages
#         done
#         foreign-env
#         pkgs.libnotify # notify-send for done
#       ];
#
#       programs.fish = {
#         enable = true;
#         shellAliases = {
#           aj = "alejandra ~/nix-setup";
#           ls = "eza";
#           ll = "eza -l";
#           lt = "eza -T";
#         };
#         shellAbbrs = {
#           gs = "git status";
#           cd = "z";
#           df = "duf";
#           ga = "git add";
#           lg = "lazygit";
#           ld = "lazydocker";
#           nos = "aj && nh os switch";
#           nosu = "aj && nh os switch --update";
#           nost = "aj && nh os test";
#         };
#         interactiveShellInit = ''
#           bind up _atuin_bind_up
#
#           set -gx EDITOR "nvim"
#           enable_transience
#
#           if status is-interactive
#               if type -q zellij
#                   # Update the zellij tab name with the current process name or pwd.
#                   function zellij_tab_name_update_pre --on-event fish_preexec
#                       if set -q ZELLIJ
#                           set -l cmd_line (string split " " -- $argv)
#                           set -l process_name $cmd_line[1]
#                           if test -n "$process_name" -a "$process_name" != "z"
#                               command nohup zellij action rename-tab $process_name >/dev/null 2>&1
#                           end
#                       end
#                   end
#
#                   function zellij_tab_name_update_post --on-event fish_postexec
#                       if set -q ZELLIJ
#                           set -l cmd_line (string split " " -- $argv)
#                           set -l process_name $cmd_line[1]
#                           if test "$process_name" = "z"
#                               command nohup zellij action rename-tab (prompt_pwd) >/dev/null 2>&1
#                           end
#                       end
#                   end
#               end
#           end
#         '';
#         plugins = [
#           {
#             name = "replay";
#             src = pkgs.fetchFromGitHub {
#               owner = "jorgebucaran";
#               repo = "replay.fish";
#               rev = "d2ecacd3fe7126e822ce8918389f3ad93b14c86c";
#               hash = "sha256-TzQ97h9tBRUg+A7DSKeTBWLQuThicbu19DHMwkmUXdg=";
#             };
#           }
#           {
#             name = "pisces";
#             src = pkgs.fishPlugins.pisces;
#           }
#           {
#             name = "fzf";
#             src = pkgs.fishPlugins.fzf-fish;
#           }
#           {
#             name = "bass";
#             src = pkgs.fishPlugins.bass;
#           }
#           {
#             name = "done";
#             src = pkgs.fishPlugins.done;
#           }
#           {
#             name = "you-should-use";
#             src = pkgs.fishPlugins.fish-you-should-use;
#           }
#           {
#             name = "z";
#             src = pkgs.fishPlugins.z;
#           }
#         ];
#       };
#     };
#   };
# }

