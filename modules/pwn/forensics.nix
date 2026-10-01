{chimera, ...}: {
  chimera.pwn.provides.forensics.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [
      # Disk Imaging & Recovery
      # guymager for live acquisition, libewf to read the resulting E01,
      # sleuthkit (fls/icat/istat) for filesystem timeline work.
      guymager
      libewf
      sleuthkit

      # Memory Forensics
      volatility3

      # File Carving
      binwalk
      foremost

      # Artifact Extraction & Triage
      exiftool

      # Log / Timeline Analysis
      ripgrep-all

      # Pattern & Binary Analysis
      yara-x
      capa

      # Data Inspection
      # sqlite-utils pulls in the sqlite CLI.
      sqlite-utils
    ];
  };
}