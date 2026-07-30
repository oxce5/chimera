{
  chimera.wayland.provides.vicinae.homeManager = {
    programs.vicinae = {
      enable = true;
      systemd.enable = true;
    };
    wayland.windowManager.niri.settings.binds = {
      "Mod+Space" = {
        _props.hotkey-overlay-title = "Application Launcher";
        spawn = ["vicinae" "toggle"];
      };
    };
  };
}
