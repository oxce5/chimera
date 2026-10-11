{chimera, ...}: {
  chimera.pwn.provides.re.homeManager = {pkgs, ...}: let
    cutter = pkgs.cutter.overrideAttrs (_: {
      preBuild = ''
        runtimePythonPath=$(
          echo "$PYTHONPATH" |
          tr ':' '\n' |
          grep -v 'shiboken6-generator' |
          paste -sd: -
        )
        qtWrapperArgs+=(--prefix PYTHONPATH : "$runtimePythonPath")
      '';
    });
  in {
    programs.rizin = {
      enable = true;
      package = pkgs.rizin.withPlugins (ps: [ps.rz-ghidra ps.sigdb]);
      settings = {
        "bin.relocs.apply" = true;
        "ghidra.roprop" = 2;
        "ghidra.rawptr" = false;
        "bin.demangle" = true;
      };
    };

    home.packages = [
      cutter
    ];
  };
}
