{
  chimera.xdg = {
    nixos.xdg.terminal-exec.enable = true;
    homeManager = {
      config,
      lib,
      pkgs,
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
          # music = null;
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
            # "org.freedesktop.impl.portal.Screenshot" = "gnome";
          };
        };
      };
      # home.sessionVariables = {
      #   # cleaning up ~
      #   ANDROID_USER_HOME = "${config.xdg.dataHome}/android";
      #   CARGO_HOME = "${config.xdg.dataHome}/cargo";
      #   CUDA_CACHE_PATH = "${config.xdg.cacheHome}/nv";
      #   DOTNET_CLI_HOME = "${config.xdg.dataHome}/dotnet";
      #   GOPATH = "${config.xdg.dataHome}/go";
      #   GRADLE_USER_HOME = "${config.xdg.dataHome}/gradle";
      #   _JAVA_OPTIONS = "-Djava.util.prefs.userRoot=${config.xdg.configHome}/java";
      #   LESSHISTFILE = "${config.xdg.cacheHome}/less/history";
      #   MPLAYER_HOME = "${config.xdg.configHome}/mplayer";
      #   NODE_REPL_HISTORY = "${config.xdg.stateHome}/node_repl_history";
      #   NPM_CONFIG_INIT_MODULE = "${config.xdg.configHome}/npm/config/npm-init.js";
      #   NPM_CONFIG_CACHE = "${config.xdg.cacheHome}/npm";
      #   NXC_PATH = "${config.xdg.configHome}/nxc";
      #   NUGET_PACKAGES = "${config.xdg.cacheHome}/NuGetPackages";
      #   OCTAVE_HISTFILE = "${config.xdg.cacheHome}/octave-hsts";
      #   OCTAVE_SITE_INITFILE = "${config.xdg.configHome}/octave/octaverc";
      #   STACK_ROOT = "${config.xdg.dataHome}/stack";
      #   PYTHON_HISTORY = "${config.xdg.configHome}/python/history";
      #   WINEPREFIX = "${config.xdg.dataHome}/wine";
      #   XCOMPOSECACHE = "${config.xdg.cacheHome}/X11/xcompose";
      #   _Z_DATA = "${config.xdg.dataHome}/z";
      # };
    };
  };
}
