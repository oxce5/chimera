{chimera, ...}: {
  chimera.pwn.provides.sniff.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [
      # Sniffing & Spoofing
      # wireshark
      bettercap
      python3Packages.scapy
    ];
  };
}
