{chimera, ...}: {
  chimera.pwn.provides.forensics.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [
      # Filesystem timeline / analysis (fls, icat, istat)
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

  # guymager needs Qt5 + mono and propagates qttools' *dev* output into the
  # closure, which costs ~2.6 GiB on its own. Disk *imaging* only, so it is
  # opt-in: include <chimera/pwn/forensics/imaging> where you actually acquire
  # images (libewf/sleuthkit above are enough to read the results).
  chimera.pwn.provides.forensics.imaging.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [
      # Disk Imaging & Recovery
      # guymager for live acquisition, libewf to read the resulting E01,
      # sleuthkit (fls/icat/istat) for filesystem timeline work.
      guymager
      libewf
    ];
  };
}
