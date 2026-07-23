{
  inputs,
  lib,
  chimera,
  _findFile,
  ...
}: {
  chimera.pwn = {
    nixos = {
      environment.etc.hosts.mode = "0644";
      programs.wireshark.enable = true;
      virtualisation.docker.enable = true;
      networking.firewall.trustedInterfaces = ["tun0"];
    };
    homeManager = {
      pkgs,
      config,
      ...
    }: {
      home.packages = with pkgs; let
        wordlists = pkgs.wordlists.override {
          lists = [
            pkgs.nmap
            pkgs.rockyou
            pkgs.seclists
          ];
        };
      in [
        # general
        wordlists
        # Information Gathering
        nmap
        theharvester
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

        # Vulnerability Analysis
        sqlmap
        bruno

        # Exploitation Tools
        exploitdb
        responder
        netexec
        python3Packages.impacket

        # Sniffing & Spoofing
        # wireshark
        bettercap
        python3Packages.scapy
        mitmproxy
        mitmproxy2swagger

        # Password Attacks
        thc-hydra
        hashcat
        hashcat-utils
        john
        ophcrack

        # Web Application Analysis
        whatweb
        ffuf
        xh
        wpscan
        # dalfox
        # wafw00f
        # graphw00f

        # Reverse Engineering
        # ghidra
        # cutter
        # imhex

        # Social Engineering Tools
        # social-engineer-toolkit

        # windows :(
        python314Packages.bloodyad

        # Miscellaneous
        openvpn
        # tor-browser
        (writeScriptBin "cyberchef" ''
          ${lib.getExe' xdg-utils "xdg-open"} ${cyberchef}/share/cyberchef/index.html
        '')

        (inputs.wrapper-manager.lib.wrapWith pkgs {
          basePackage = pkgs.rustscan;
          prependFlags = ["-c ${config.xdg.configHome}/rustscan.toml"];
        })
        (inputs.wrapper-manager.lib.wrapWith pkgs {
          basePackage = pkgs.metasploit;
          programs.msfconsole.prependFlags = ["--defer-module-loads"];
        })
      ];
    };
  };
}
