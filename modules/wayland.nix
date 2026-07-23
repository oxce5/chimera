{
  chimera.wayland._.base = {host, ...}: {
    nixos = {
      pkgs,
      lib,
      ...
      }: {
        programs = {
          dconf.enable = true;
          appimage = {
            enable = true;
            binfmt = true;
          };
        };
        environment = {
          systemPackages = [pkgs.wl-clipboard];
          sessionVariables = {
            NIXOS_OZONE_WL = "1";
            # XCURSOR_SIZE = lib.mkForce (builtins.ceil (32 * host.primaryDisplay.scaling));
          };
        };

        services.pipewire = {
          enable = true;
          alsa.enable = true;       
          alsa.support32Bit = true; 
          pulse.enable = true;      
          jack.enable = true;       
          wireplumber.enable = true;
        };
      };

    homeManager = {config, ...}: {
      qt.enable = true;
      gtk = {
        enable = true;
        gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
        gtk3.bookmarks = [
          "file:///home/oxce5/Downloads Downloads"
          "file:///home/oxce5/Documents Documents"
          "file:///home/oxce5/Pictures Pictures"
          "file:///home/oxce5/Videos Videos"
          "file:///home/oxce5/Games Games"
        ];
      };
    };
  };
}
