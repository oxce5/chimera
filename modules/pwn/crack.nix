{chimera, ...}: {
  chimera.pwn.provides.crack.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [
      # Password Attacks
      thc-hydra
      hashcat
      hashcat-utils
      john
    ];
  };
}
