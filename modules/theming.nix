{
  inputs,
  chimera,
  ...
}: {
  chimera.theming = {
    nixos = {
      pkgs,
      lib,
      ...
    }: {
      fonts = {
        packages = [
          (inputs.chimera-pkgs.packages.${pkgs.stdenv.hostPlatform.system}.iosevka-chimera)
        ];
        enableDefaultPackages = true;
        fontDir.enable = lib.mkDefault false;
        fontconfig.defaultFonts = {
          monospace = ["Iosevka Chimera"];
        };
      };
    };
  };

  # Desktop-only fonts. The VM only gets iosevka-chimera globally.
  chimera.theming.provides.desktop = {
    nixos = {
      pkgs,
      lib,
      ...
    }: {
      fonts = {
        packages = with pkgs; [
          maple-mono.NF
          montserrat
          libertine
          inter
          openmoji-color
          nerd-fonts.symbols-only
          atkinson-hyperlegible-next
        ];
        fontconfig.defaultFonts = {
          sansSerif = ["Atkinson Hyperlegible Next"];
          serif = ["Liberation Serif"];
          emoji = ["OpenMoji Color"];
        };
      };
    };
  };

  # Declarative base theming, managed by NixOS/Home Manager. This is the
  # fallback when no runtime theme manager (noctalia) is present: colors are
  # fixed at build time and everything follows them.
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

  # Noctalia-driven system-wide theming. Used only when the noctalia desktop
  # shell is present: noctalia owns the palette at runtime and renders theme
  # files for GTK/Qt/terminal/KDE apps, so nothing here hardcodes colors.
  chimera.theming.provides.noctalia = {
    includes = [chimera.theming.provides.desktop];
    homeManager = {
      config,
      pkgs,
      ...
    }: {
      imports = [inputs.noctalia.homeModules.default];

      programs.noctalia = {
        enable = true;
        package = pkgs.noctalia;

        settings = {
          theme = {
            mode = "dark";
            source = "builtin";
            builtin = "Noctalia";

            templates = {
              enable_builtin_templates = true;
              builtin_ids = ["gtk3" "gtk4" "qt" "kcolorscheme" "kitty"];
            };
          };
        };
      };

      # GTK follows the noctalia-generated palette via the gtk3/gtk4 built-in
      # templates (noctalia.css + adw-gtk3/color-scheme sync).
      home.packages = with pkgs; [
        adw-gtk3
        qt6Packages.qt6ct
      ];

      # Qt follows the noctalia-generated color scheme via qt6ct.
      home.sessionVariables.QT_QPA_PLATFORMTHEME = "qt6ct";
      xdg.configFile."qt6ct/qt6ct.conf".text = ''
        [Appearance]
        color_scheme_path=${config.xdg.configHome}/qt6ct/colors/noctalia.conf
      '';
    };
  };
}
