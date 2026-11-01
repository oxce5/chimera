{lib, ...}: let
  # number in "Adachi Rei_NN.ani" -> Xcursor name
  mapping = {
    "01" = "left_ptr";
    "02" = "help";
    "03" = "progress";
    "04" = "wait";
    "05" = "crosshair";
    "06" = "text";
    "07" = "pencil";
    "08" = "not-allowed";
    "09" = "ns-resize";
    "10" = "ew-resize";
    "11" = "nwse-resize";
    "12" = "nesw-resize";
    "13" = "move";
    "14" = "center_ptr";
    "15" = "pointer";
  };

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

  mkRei = {
    stdenvNoCC,
    unzip,
    win2xcur,
  }: let
    convertCmds = lib.concatStringsSep "\n" (lib.mapAttrsToList (num: name: ''
        src=$(find unpacked -type f -name "Adachi Rei_${num}.ani" | head -n1)
        if [ -z "$src" ]; then
          echo "missing in zip: Adachi Rei_${num}.ani" >&2
          exit 1
        fi
        cp "$src" "$work/${name}.ani"
        win2xcur "$work/${name}.ani" -o "$cursors"
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
      pname = "adachi-rei-cursor";
      version = "1";

      src = ./rei.zip;
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

        printf '[Icon Theme]\nName=AdachiRei\nComment=Converted Windows cursor pack\n' > build/index.theme
        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall
        mkdir -p $out/share/icons
        cp -r build $out/share/icons/AdachiRei
        runHook postInstall
      '';

      meta = {
        description = "Adachi Rei animated cursor theme (converted from a Windows pack)";
        platforms = lib.platforms.linux;
      };
    };

  pickWin2xcur = pkgs: pkgs.win2xcur or pkgs.python3Packages.win2xcur;
in {
  perSystem = {pkgs, ...}: {
    packages.adachi-rei-cursor = mkRei {
      inherit (pkgs) stdenvNoCC unzip;
      win2xcur = pickWin2xcur pkgs;
    };
  };

  flake.overlays.adachi-rei-cursor = final: _prev: {
    adachi-rei-cursor = mkRei {
      inherit (final) stdenvNoCC unzip;
      win2xcur = pickWin2xcur final;
    };
  };
}
