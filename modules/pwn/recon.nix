{chimera, ...}: {
  chimera.pwn.provides.recon.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [
      # Information Gathering
      nmap
      enum4linux-ng
      smbmap
      feroxbuster
      sherlock
      amass
      waymore
      # ProjectDiscovery tools
      # (inputs.wrapper-manager.lib.wrapWith pkgs {
      #   basePackage = pkgs.subfinder;
      #   env.SUBFINDER_PROVIDER_CONFIG.value = "${config.sops.templates."subfinder-providers.yaml".path}";
      # })
      # alterx
      # dnsx
      # naabu
      httpx
      nuclei
      # uncover
      # cloudlist
      # tlsx
      # notify
      # mapcidr
      interactsh
      # katana
      # cvemap
      # shuffledns
      massdns

      # uro
      # secrethound
      # inputs.mypkgs.packages.${sys}.gf
    ];
  };
}
