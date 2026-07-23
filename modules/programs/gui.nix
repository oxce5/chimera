{inputs, __findFile, withSystem, ...}: {
  chimera.apps._.gui = {
    includes = [ <chimera/browser/firefox> ];
    homeManager = {pkgs, ...}: {
      
      home.packages = with pkgs; [
        kitty
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


        (withSystem pkgs.stdenv.hostPlatform.system (p: p.config.packages.blender-beta))
        (inputs.kopuz.packages.${pkgs.stdenv.hostPlatform.system}.default)
        vesktop
      ];
    };
  };
}
