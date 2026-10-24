{
  inputs,
  chimera,
  ...
}: {
  chimera.pwn.provides.c2 = {
    nixos = {
      imports = [inputs.chimera-pkgs.nixosModules.sliver];
      services.sliver = {
        enable = true;
        # Whole 240/4 local on lo: portfwd --bind addresses must stay local,
        # and Burp/browsers skip the proxy for 127.0.0.0/8.
        portfwdAddresses = ["240.0.0.1/4"];
      };
    };
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        penelope
      ];
    };
  };
}
