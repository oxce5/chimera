{inputs, ...}: {
  chimera.apps._.gui.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [
      libreoffice
      hunspell
      hunspellDicts.en_US-large
      remmina
      # (bottles.override { removeWarningPopup = true; })
      varia
      # proton-pass
      # element-desktop
      # obsidian
      # orca-slicer
      # freecad
      # gearlever
      # dino

      (inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default)
      (inputs.kopuz.packages.${pkgs.stdenv.hostPlatform.system}.default)
      vesktop
    ];
  };
}
