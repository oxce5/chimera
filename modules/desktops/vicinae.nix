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
      "Mod+V" = {
        _props.hotkey-overlay-title = "Open Vicinae clipboard";
        spawn = ["vicinae" "cmd" "launch" "clipboard:history"];
      };
      "Mod+M" = {
        _props.hotkey-overlay-title = "Open Vicinae process manager";
        spawn = ["vicinae" "cmd" "launch" "@leonkohli/store.vicinae.process-manager:processes"];
      };
    };
  };
}
