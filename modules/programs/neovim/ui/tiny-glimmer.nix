# chimera.nvf.ui.tiny-glimmer — yank/search/paste animation (full profile only).
{...}: {
  chimera.nvf.ui = {
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      programs.nvf.settings.vim.lazy.plugins."tiny-glimmer.nvim" = {
        package = pkgs.vimPlugins.tiny-glimmer-nvim;
        event = ["TextYankPost"];
        setupModule = "tiny-glimmer";
        # Ported verbatim from ~/.config/nvim/lua/plugins/ui/tiny-glimmer.lua.
        # All plain data (the custom animation example is commented out).
        setupOpts = {
          disable_warnings = true;
          autoreload = false;
          refresh_interval_ms = 8;
          text_change_batch_timeout_ms = 50;
          overwrite = {
            auto_map = true;
            yank = {
              enabled = true;
              default_animation = "fade";
            };
            search = {
              enabled = false;
              default_animation = "pulse";
              next_mapping = "n";
              prev_mapping = "N";
            };
            paste = {
              enabled = true;
              default_animation = "reverse_fade";
              paste_mapping = "p";
              Paste_mapping = "P";
            };
            undo = {
              enabled = false;
              default_animation = {
                name = "fade";
                settings = {
                  from_color = "DiffDelete";
                  max_duration = 500;
                  min_duration = 500;
                };
              };
              undo_mapping = "u";
            };
            redo = {
              enabled = false;
              default_animation = {
                name = "fade";
                settings = {
                  from_color = "DiffAdd";
                  max_duration = 500;
                  min_duration = 500;
                };
              };
              redo_mapping = "<c-r>";
            };
          };
          transparency_color = null;
          animations = {
            fade = {
              max_duration = 400;
              min_duration = 300;
              easing = "outQuad";
              chars_for_max_duration = 10;
              from_color = "Visual";
              to_color = "Normal";
              font_style = {};
            };
            reverse_fade = {
              max_duration = 380;
              min_duration = 300;
              easing = "outBack";
              chars_for_max_duration = 10;
              from_color = "Visual";
              to_color = "Normal";
              font_style = {};
            };
            bounce = {
              max_duration = 500;
              min_duration = 400;
              chars_for_max_duration = 20;
              oscillation_count = 1;
              from_color = "Visual";
              to_color = "Normal";
              font_style = {};
            };
            left_to_right = {
              max_duration = 350;
              min_duration = 350;
              min_progress = 0.85;
              chars_for_max_duration = 25;
              lingering_time = 50;
              from_color = "Visual";
              to_color = "Normal";
              font_style = {};
            };
            pulse = {
              max_duration = 600;
              min_duration = 400;
              chars_for_max_duration = 15;
              pulse_count = 2;
              intensity = 1.2;
              from_color = "Visual";
              to_color = "Normal";
              font_style = {};
            };
            rainbow = {
              max_duration = 600;
              min_duration = 350;
              chars_for_max_duration = 20;
              font_style = {};
            };
          };
          hijack_ft_disabled = [
            "alpha"
            "snacks_dashboard"
          ];
          virt_text = {
            priority = 2048;
          };
        };
      };
    };
  };
}
