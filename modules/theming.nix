{inputs, ...}: {
  chimera.theming = {
    nixos = {pkgs, ...}: {
      fonts = {
        packages = with pkgs; [
          maple-mono.NF
          (inputs.chimera-pkgs.packages.${pkgs.stdenv.hostPlatform.system}.iosevka-chimera)
          montserrat
          libertine
          inter
          openmoji-color
          nerd-fonts.symbols-only
          atkinson-hyperlegible-next
        ];
        enableDefaultPackages = true;
        fontDir.enable = true;
        fontconfig.defaultFonts = {
          sansSerif = ["Atkinson Hyperlegible Next"];
          serif = ["Liberation Serif"];
          monospace = ["Iosevka Chimera"];
          emoji = ["OpenMoji Color"];
        };
      };
    };
  };
}
