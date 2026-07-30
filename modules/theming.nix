{inputs, ...}: {
  chimera.theming = {
    nixos = {
      pkgs,
      lib,
      ...
    }: {
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
        fontDir.enable = lib.mkDefault false;
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
