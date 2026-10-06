{chimera, ...}: {
  # Declarative base theming, managed by NixOS/Home Manager. This is the
  # fallback when no runtime theme manager (noctalia) is present: colors are
  # fixed at build time and everything follows them.
  #
  # Currently only reached via chimera.desktop-shells.provides.dms, which is
  # itself parked.
  chimera.theming.provides.declarative = {
    includes = [chimera.theming.provides.desktop];
    homeManager = {pkgs, ...}: {
      gtk = {
        theme = {
          name = "adw-gtk3-dark";
          package = pkgs.adw-gtk3;
        };
        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
        };
      };
      qt = {
        platformTheme.name = "gtk3";
        style = {
          name = "adwaita-dark";
          package = pkgs.adwaita-qt;
        };
      };
    };
  };
}
