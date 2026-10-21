{
  chimera.xdg = {
    nixos.xdg.terminal-exec.enable = true;
    homeManager = {
      config,
      pkgs,
      lib,
      ...
    }: {
      xdg = {
        enable = true;
        autostart.enable = true;
        autostart.readOnly = true;

        userDirs = {
          enable = true;
          setSessionVariables = false;
          createDirectories = true;
          desktop = null;
          templates = null;
          projects = "${config.home.homeDirectory}/Projects";
          music = "${config.home.homeDirectory}/Music";
          publicShare = null;
        };

        portal = {
          enable = true;
          xdgOpenUsePortal = true;
          extraPortals = with pkgs; [
            xdg-desktop-portal-termfilechooser
            xdg-desktop-portal-gtk
            xdg-desktop-portal-gnome
          ];
          config.common = {
            "default" = "gtk";
            "org.freedesktop.impl.portal.FileChooser" = "termfilechooser";
            "org.freedesktop.impl.portal.ScreenCast" = "gnome";
            "XDG_CURRENT_DESKTOP" = "niri";
          };
          config.niri = {
            "default" = lib.mkForce "gtk";
            "org.freedesktop.impl.portal.FileChooser" = lib.mkForce "termfilechooser";
            "org.freedesktop.impl.portal.ScreenCast" = "gnome";
            "XDG_CURRENT_DESKTOP" = "niri";
          };
        };
      };
    };
  };
}
