# flake-parts module + derivation in one file
{lib, ...}: let
  # file name inside the zip -> Xcursor name
  mapping = {
    "normal.ani" = "left_ptr";
    "alternate select.ani" = "center_ptr";
    "help.ani" = "help";
    "background.ani" = "progress";
    "busy.ani" = "wait";
    "precision.cur" = "crosshair";
    "text.ani" = "text";
    "pen.cur" = "pencil";
    "unavailable.ani" = "not-allowed";
    "vertical.ani" = "ns-resize";
    "horizontal.ani" = "ew-resize";
    "diagonal 1.cur" = "nwse-resize";
    "diagonal 2.cur" = "nesw-resize";
    "move.cur" = "move";
    "link.ani" = "pointer";
  };

  # target -> alternate names that symlink to it
  aliases = {
    left_ptr = ["arrow" "default" "top_left_arrow" "left-arrow"];
    pointer = [
      "hand1"
      "hand2"
      "pointing_hand"
      "9d800788f1b08800ae810202380a0822"
      "e29285e634086352946a0e7090d73106"
    ];
    text = ["xterm" "ibeam"];
    wait = ["watch"];
    progress = [
      "left_ptr_watch"
      "08e8e1c95fe2fc01f976f1e063a24ccd"
      "3ecb610c1bf2410f44200f48c40d3599"
    ];
    help = [
      "question_arrow"
      "whats_this"
      "d9ce0ab605698f320427677b458ad60b"
      "5c6cd98b3f3ebcb1f9c7f1c204630408"
    ];
    crosshair = ["cross" "tcross"];
    move = ["fleur" "all-scroll" "size_all"];
    ns-resize = [
      "sb_v_double_arrow"
      "size_ver"
      "row-resize"
      "v_double_arrow"
      "double_arrow"
      "00008160000006810000408080010102"
    ];
    ew-resize = [
      "sb_h_double_arrow"
      "size_hor"
      "col-resize"
      "h_double_arrow"
      "14fef782d02440884392942c11205230"
    ];
    nwse-resize = [
      "size_fdiag"
      "bd_double_arrow"
      "38c5dff7c7b8962045400281044508ae"
    ];
    nesw-resize = [
      "size_bdiag"
      "fd_double_arrow"
      "c7088f0f3e6c8088236ef8e1e3e70000"
    ];
    not-allowed = [
      "crossed_circle"
      "forbidden"
      "no-drop"
      "circle"
      "03b6e0fcb3499374a867c041f52298f0"
    ];
  };

  mkTeto = {
    stdenvNoCC,
    unzip,
    win2xcur,
  }: let
    convertCmds = lib.concatStringsSep "\n" (lib.mapAttrsToList (file: name: let
        ext = lib.last (lib.splitString "." file);
      in ''
        src=$(find unpacked -type f -name ${lib.escapeShellArg file} | head -n1)
        if [ -z "$src" ]; then
          echo "missing in zip: ${file}" >&2
          exit 1
        fi
        cp "$src" "$work/${name}.${ext}"
        win2xcur "$work/${name}.${ext}" -o "$cursors"
      '')
      mapping);

    aliasCmds = lib.concatStringsSep "\n" (lib.mapAttrsToList (
        target: names:
          lib.concatMapStringsSep "\n"
          (a: "ln -sf ${target} ${lib.escapeShellArg a}")
          names
      )
      aliases);
  in
    stdenvNoCC.mkDerivation {
      pname = "teto-cursor";
      version = "1";

      src = ./teto.zip;
      dontUnpack = true;
      nativeBuildInputs = [unzip win2xcur];

      buildPhase = ''
        runHook preBuild
        unzip -q "$src" -d unpacked

        work=$(mktemp -d)
        cursors=build/cursors
        mkdir -p "$cursors"

        ${convertCmds}

        pushd "$cursors"
        ${aliasCmds}
        popd

        printf '[Icon Theme]\nName=Teto\nComment=Converted Windows cursor pack\n' > build/index.theme
        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall
        mkdir -p $out/share/icons
        cp -r build $out/share/icons/Teto
        runHook postInstall
      '';

      meta = {
        description = "Teto animated cursor theme (converted from a Windows pack)";
        platforms = lib.platforms.linux;
      };
    };

  pickWin2xcur = pkgs: pkgs.win2xcur or pkgs.python3Packages.win2xcur;
in {
  perSystem = {
    pkgs,
    config,
    ...
  }: {
    packages.teto-cursor = mkTeto {
      inherit (pkgs) stdenvNoCC unzip;
      win2xcur = pickWin2xcur pkgs;
    };
    packages.default = config.packages.teto-cursor;
  };

  flake.overlays.teto-cursor = final: _prev: {
    teto-cursor = mkTeto {
      inherit (final) stdenvNoCC unzip;
      win2xcur = pickWin2xcur final;
    };
  };
}
