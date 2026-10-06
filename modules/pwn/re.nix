{chimera, ...}: {
  chimera.pwn.provides.re.homeManager = {pkgs, ...}: {
    programs.rizin = {
      enable = true;
      package = pkgs.rizin.withPlugins (ps: [ ps.rz-ghidra ps.sigdb ]);
      settings = {
        "bin.relocs.apply" = true;
        "ghidra.roprop" = 2;
        "ghidra.rawptr" = false;
        "bin.demangle" = true;
      };
    };

    home.packages = [
      pkgs.cutter
    ];
  };
}
