{chimera, ...}: {
  chimera.pwn.provides.re.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [
      # radare2-style RE with Ghidra's decompiler backend (rz-ghidra).
      # `pdg @ fcn` prints pseudo-C for a function.
      (rizin.withPlugins (p: with p; [
        rz-ghidra
      ]))
      # cutter (rizin GUI, has the decompiler pane too)
    ];
  };
}