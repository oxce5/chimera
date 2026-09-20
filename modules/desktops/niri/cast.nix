{chimera, ...}: {
  chimera.wayland.provides.cast.homeManager = {
    wayland.windowManager.niri.settings = {
      binds = {
        "Ctrl+Shift+R" = {
          _props = {
            hotkey-overlay-title = "Dynamic Cast: Window";
            allow-inhibiting = false;
          };
          set-dynamic-cast-window = [];
        };
        "Ctrl+Shift+D" = {
          _props = {
            hotkey-overlay-title = "Dynamic Cast: Clear";
            allow-inhibiting = false;
          };
          clear-dynamic-cast-target = [];
        };
      };

      # NOTE: a second window-rule block can only be expressed as a
      # top-level _children singleton. A nested window-rule._children
      # inlines into a single block (merging all matches, which forced
      # cast windows to 1300x720), and a plain list renders as invalid
      # `-` nodes.
      _children = [
        {
          window-rule = {
            match = {
              _props = {"is-window-cast-target" = true;};
            };
            focus-ring = {
              on = [];
              width = 4;
              active-color = "#ff0000";
              inactive-color = "#7d0d2d";
            };
          };
        }
      ];
    };
  };
}
