{
  inputs,
  __findFile,
  withSystem,
  ...
}: {
  chimera.apps._.gui = {
    includes = [<chimera/browser/firefox>];
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        kitty
        krita
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

        # (withSystem pkgs.stdenv.hostPlatform.system (p: p.config.packages.blender-beta))
        (inputs.wrapper-manager.lib.wrapWith pkgs {
          basePackage = pkgs.blender;
          env = {
            __NV_PRIME_RENDER_OFFLOAD.value = "1";
            __NV_PRIME_RENDER_OFFLOAD_PROVIDER.value = "NVIDIA-G0";
            __GLX_VENDOR_LIBRARY_NAME.value = "nvidia";
            __VK_LAYER_NV_optimus.value = "NVIDIA_only";
          };
        })
        # (inputs.kopuz.packages.${pkgs.stdenv.hostPlatform.system}.default)
        pear-desktop
        vesktop
      ];
    };
  };
}
