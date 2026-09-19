{chimera, ...}: {
  chimera.pwn.provides.web.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [
      # Web Application Analysis
      whatweb
      ffuf
      xh
      wpscan
      burpsuite
      # dalfox
      # wafw00f
      # graphw00f
    ];
  };
}
