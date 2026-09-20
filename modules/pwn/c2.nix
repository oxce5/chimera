{
  inputs,
  chimera,
  ...
}: {
  chimera.pwn.provides.c2 = {
    nixos = {
      imports = [inputs.chimera-pkgs.nixosModules.sliver];
      services.sliver.enable = true;
    };
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        penelope
      ];
    };
  };
}
