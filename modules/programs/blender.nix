{
  perSystem = {pkgs, ...}: let
    libs = [pkgs.wayland pkgs.libdecor pkgs.libx11 pkgs.libxi pkgs.libxxf86vm pkgs.libxfixes pkgs.libxrender pkgs.libxkbcommon pkgs.libGLU pkgs.libglvnd pkgs.numactl pkgs.SDL2 pkgs.libdrm pkgs.ocl-icd pkgs.stdenv.cc.cc.lib pkgs.openal pkgs.alsa-lib pkgs.pulseaudio pkgs.libsm pkgs.libice pkgs.zlib pkgs.vulkan-loader];
  in {
    packages.blender-beta = pkgs.stdenv.mkDerivation {
      pname = "blender-bin";
      version = "5.3.0";

      src = pkgs.fetchurl {
        url = "https://cdn.builder.blender.org/download/daily/blender-5.3.0-beta+v53.ecaf39c37b28-linux.x86_64-release.tar.xz";
        hash = "sha256-E6uJ4YSgh1nfOOncaVF3m+Z06qFvQNF4DeAZOQFe8Do=";
      };

      buildInputs = [pkgs.makeWrapper];

      preUnpack = ''
        mkdir -p $out/libexec
        cd $out/libexec
      '';

      installPhase = ''
        cd $out/libexec
        mv blender-* blender

        mkdir -p $out/share/applications
        mkdir -p $out/share/icons/hicolor/scalable/apps
        mv ./blender/blender.desktop $out/share/applications/blender.desktop
        mv ./blender/blender.svg $out/share/icons/hicolor/scalable/apps/blender.svg

        mkdir $out/bin

        makeWrapper $out/libexec/blender/blender $out/bin/blender \
          --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib:${pkgs.lib.makeLibraryPath libs}

        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
          blender/blender

        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)"  \
          $out/libexec/blender/*/python/bin/python3*
      '';

      meta.mainProgram = "blender";
    };
  };
}
