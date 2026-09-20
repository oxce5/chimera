{chimera, ...}: {
  chimera.pwn.provides.ad = {
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        # windows :(
        # ^ thank you pythonMetadataCheckPhase
        # python314Packages.bloodyad
        bloodhound-ce
        rusthound-ce
      ];
    };
  };
}
