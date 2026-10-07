{lib, ...}: {
  chimera.wayland.provides.niri.homeManager = let
    dirs = ["left" "down" "up" "right"];

    # Columns are laid out left/right; windows stack up/down inside one.
    isColumn = d: d == "left" || d == "right";

    arrows = {
      left = ["Left"];
      down = ["Down"];
      up = ["Up"];
      right = ["Right"];
    };
    vim = {
      left = ["H"];
      down = ["J"];
      up = ["K"];
      right = ["L"];
    };

    horizontalArrows = {
      left = ["Left"];
      right = ["Right"];
      down = [];
      up = [];
    };

    verticalPageKeys = {
      down = ["Page_Down" "U"];
      up = ["Page_Up" "I"];
    };
    verticalArrowKeys = {
      down = ["Down" "U"];
      up = ["Up" "I"];
    };

    # Union two spelling tables, concatenating per direction.
    keys = a: b: lib.mapAttrs (dir: x: a.${dir} ++ b.${dir}) a;

    # Both the arrow and the hjkl spelling of every direction.
    arrowsAndVim = keys arrows vim;

    # Monitor focus only spells the horizontal directions with arrows; the
    # hjkl keys still cover all four.
    horizontalArrowsAndVim = keys horizontalArrows vim;

    # A navigation family: one action per direction, bound to every key
    # spelling of that direction under one prefix.
    nav = prefix: spellings: actionFor:
      lib.foldl' (
        acc: dir:
          acc
          // lib.listToAttrs (
            map (key: {
              name = "${prefix}${key}";
              value = {"${actionFor dir}" = [];};
            })
            spellings.${dir} or []
          )
      ) {}
      dirs;

    focusNav = nav "Mod+" arrowsAndVim (
      d:
        if isColumn d
        then "focus-column-${d}"
        else "focus-window-${d}"
    );

    windowMove = nav "Mod+Shift+" arrowsAndVim (
      d:
        if isColumn d
        then "move-column-${d}"
        else "move-window-${d}"
    );

    monitorFocus = nav "Mod+Ctrl+" horizontalArrowsAndVim (d: "focus-monitor-${d}");

    moveToMonitor =
      nav "Mod+Shift+Ctrl+" arrowsAndVim (d: "move-column-to-monitor-${d}");

    workspaceFocus = nav "Mod+" verticalPageKeys (d: "focus-workspace-${d}");

    workspaceMove = nav "Mod+Shift+" verticalPageKeys (d: "move-workspace-${d}");

    columnToWorkspace =
      nav "Mod+Ctrl+" verticalArrowKeys (d: "move-column-to-workspace-${d}");

    numberedWorkspaces = lib.listToAttrs (
      map (n: {
        name = "Mod+${toString n}";
        value = {focus-workspace = n;};
      }) (lib.range 1 9)
    );

    numberedWorkspaceMove = lib.listToAttrs (
      map (n: {
        name = "Mod+Shift+${toString n}";
        value = {move-column-to-workspace = n;};
      }) (lib.range 1 9)
    );
  in {
    wayland.windowManager.niri.settings.binds =
      {
        # === System & Overview ===
        "Mod+D" = {
          _props.repeat = false;
          toggle-overview = [];
        };
        "Mod+Tab" = {
          _props.repeat = false;
          toggle-overview = [];
        };
        "Mod+Shift+Slash" = {show-hotkey-overlay = [];};

        # === Application Launchers ===
        "Mod+Return" = {
          _props.hotkey-overlay-title = "Open Terminal (multiplexed)";
          spawn-sh = "kitty -e herdr";
        };
        "Mod+T" = {
          _props.hotkey-overlay-title = "Open Terminal";
          spawn = "kitty";
        };
        # Mod+B is not here: the browser aspect (chimera.browser.provides.*)
        # owns it, so the key follows whichever browser the host actually has.

        # === Security ===
        "Mod+Shift+E" = {quit = [];};

        # === Window Management ===
        "Mod+Q" = {
          _props.repeat = false;
          close-window = [];
        };
        "Mod+F" = {maximize-column = [];};
        "Mod+Ctrl+F" = {toggle-windowed-fullscreen  = [];};
        "Mod+Shift+F" = {fullscreen-window = [];};
        "Mod+Shift+T" = {toggle-window-floating = [];};
        "Mod+Shift+V" = {switch-focus-between-floating-and-tiling = [];};
        "Mod+W" = {toggle-column-tabbed-display = [];};
      }
      // focusNav
      // windowMove
      // monitorFocus
      // moveToMonitor
      // workspaceFocus
      // workspaceMove
      // columnToWorkspace
      // numberedWorkspaces
      // numberedWorkspaceMove
      // {
        # === Column Navigation ===
        "Mod+Home" = {focus-column-first = [];};
        "Mod+End" = {focus-column-last = [];};
        "Mod+Ctrl+Home" = {move-column-to-first = [];};
        "Mod+Ctrl+End" = {move-column-to-last = [];};

        # === Mouse Wheel Navigation ===
        "Mod+WheelScrollDown" = {
          _props.cooldown-ms = 150;
          focus-workspace-down = [];
        };
        "Mod+WheelScrollUp" = {
          _props.cooldown-ms = 150;
          focus-workspace-up = [];
        };
        "Mod+Ctrl+WheelScrollDown" = {
          _props.cooldown-ms = 150;
          move-column-to-workspace-down = [];
        };
        "Mod+Ctrl+WheelScrollUp" = {
          _props.cooldown-ms = 150;
          move-column-to-workspace-up = [];
        };

        "Mod+WheelScrollRight" = {focus-column-right = [];};
        "Mod+WheelScrollLeft" = {focus-column-left = [];};
        "Mod+Ctrl+WheelScrollRight" = {move-column-right = [];};
        "Mod+Ctrl+WheelScrollLeft" = {move-column-left = [];};

        "Mod+Shift+WheelScrollDown" = {focus-column-right = [];};
        "Mod+Shift+WheelScrollUp" = {focus-column-left = [];};
        "Mod+Ctrl+Shift+WheelScrollDown" = {move-column-right = [];};
        "Mod+Ctrl+Shift+WheelScrollUp" = {move-column-left = [];};

        # === Column Management ===
        "Mod+BracketLeft" = {consume-or-expel-window-left = [];};
        "Mod+BracketRight" = {consume-or-expel-window-right = [];};
        "Mod+Period" = {expel-window-from-column = [];};

        # === Sizing & Layout ===
        "Mod+R" = {switch-preset-column-width = [];};
        "Mod+Shift+R" = {switch-preset-window-height = [];};
        "Mod+Ctrl+R" = {reset-window-height = [];};
        "Mod+Ctrl+F" = {expand-column-to-available-width = [];};
        "Mod+C" = {center-column = [];};
        "Mod+Ctrl+C" = {center-visible-columns = [];};

        # === Manual Sizing ===
        "Mod+Minus" = {set-column-width = "-10%";};
        "Mod+Equal" = {set-column-width = "+10%";};
        "Mod+Shift+Minus" = {set-window-height = "-10%";};
        "Mod+Shift+Equal" = {set-window-height = "+10%";};

        # === System Controls ===
        "Mod+Escape" = {
          _props.allow-inhibiting = false;
          toggle-keyboard-shortcuts-inhibit = [];
        };
        "Mod+Shift+P" = {power-off-monitors = [];};
      };
  };
}
