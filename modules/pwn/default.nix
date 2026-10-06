{
  inputs,
  chimera,
  ...
}: {
  chimera.pwn = {
    includes = [
      chimera.pwn._.core
      chimera.pwn._.c2
      chimera.pwn._.recon
      chimera.pwn._.exploit
      chimera.pwn._.sniff
      chimera.pwn._.crack
      chimera.pwn._.web
      chimera.pwn._.ad
      # chimera.pwn._.forensics
      chimera.pwn._.re
    ];
    nixos = {
      environment.etc.hosts.mode = "0644";
      programs.wireshark.enable = true;
      networking.firewall.trustedInterfaces = ["tun0"];
    };
  };
}
