{chimera, ...}: {
  # build-time fallback theme; only reached via dms, which is parked
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
