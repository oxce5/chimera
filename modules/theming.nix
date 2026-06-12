{ chimera, withSystem, ... }:
{
  chimera.theming = {
    # includes = [ (chimera.theming._.catppuccin "mocha" "mauve") ];
    nixos =
      { pkgs, ... }:
      {
        fonts = {
          packages = with pkgs; [
            maple-mono.NF
            (withSystem pkgs.stdenv.hostPlatform.system (p: p.config.packages.iosevka-chimera))
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
            sansSerif = [ "Atkinson Hyperlegible Next" ];
            serif = [ "Liberation Serif" ];
            monospace = [ "Iosevka Chimera" ];
            emoji = [ "OpenMoji Color" ];
          };
        };
      };

    # homeManager =
    #   { pkgs, ... }:
    #   {
    #     home = {
    #       pointerCursor = {
    #         package = pkgs.posy-cursors;
    #         name = "Posy_Cursor";
    #         gtk.enable = true;
    #       };
    #     };
    #   };
  };
}
