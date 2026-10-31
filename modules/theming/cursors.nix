{inputs, ...}: {
  chimera.theming.cursors.teto = {
    homeManager = {pkgs, ...}: {
      # teto.nix is a flake-parts module (import-tree imports it at the flake
      # level), not a home-manager module — reference its package output here.
      home.pointerCursor = {
        enable = true;
        name = "Teto";
        package = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.teto-cursor;
        size = 24;
        gtk.enable = true;
        x11.enable = true;
      };
    };
  };
}
