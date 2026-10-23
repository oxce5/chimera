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
  chimera.theming.desktop = {
    nixos = {pkgs, ...}: {
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

  # only reached with the noctalia shell, which owns the palette (see AGENTS.md)
  chimera.theming.noctalia = {
    includes = [chimera.theming.desktop];
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

      # GTK follows the noctalia palette
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
