{chimera, ...}: {
  chimera.wayland.screenshot.homeManager = {
    wayland.windowManager.niri.settings.binds = {
      "Mod+P" = {screenshot = [];};
      "Mod+Alt+P" = {screenshot-screen = [];};
      "Alt+P" = {screenshot-window = [];};
      Print = {screenshot = [];};
      "Ctrl+Print" = {screenshot-screen = [];};
      "Alt+Print" = {screenshot-window = [];};
    };
  };
}
