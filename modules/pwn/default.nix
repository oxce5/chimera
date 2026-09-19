{
  inputs,
  chimera,
  ...
}: {
  chimera.pwn = {
    includes = [
      chimera.pwn.provides.core
      chimera.pwn.provides.recon
      chimera.pwn.provides.exploit
      chimera.pwn.provides.sniff
      chimera.pwn.provides.crack
      chimera.pwn.provides.web
      chimera.pwn.provides.ad
    ];
    nixos = {
      imports = [inputs.chimera-pkgs.nixosModules.sliver];

      environment.etc.hosts.mode = "0644";
      programs.wireshark.enable = true;
      services.sliver.enable = true;
      virtualisation.docker.enable = true;
      networking.firewall.trustedInterfaces = ["tun0"];
    };
  };
}
