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

      # a second window-rule block needs a top-level _children singleton
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
