{inputs, ...}: {
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
}
