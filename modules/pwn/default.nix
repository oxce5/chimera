{
  inputs,
  chimera,
  ...
}: {
  chimera.pwn = {
    includes = [
      chimera.pwn.provides.core
      chimera.pwn.provides.c2
      chimera.pwn.provides.recon
      chimera.pwn.provides.exploit
      chimera.pwn.provides.sniff
      chimera.pwn.provides.crack
      chimera.pwn.provides.web
      chimera.pwn.provides.ad
      # chimera.pwn._.forensics
      chimera.pwn.provides.re
    ];
    nixos = {
      environment.etc.hosts.mode = "0644";
      programs.wireshark.enable = true;
      networking.firewall.trustedInterfaces = ["tun0"];
    };
  };
}
