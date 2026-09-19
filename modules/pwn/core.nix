{
  inputs,
  lib,
  chimera,
  ...
}: {
  chimera.pwn.provides.core.homeManager = {
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

      # C2
      (inputs.chimera-pkgs.packages.${pkgs.stdenv.hostPlatform.system}.sliver-client)

      # Reverse Engineering
      # ghidra
      # cutter
      # imhex

      # Social Engineering Tools
      # social-engineer-toolkit

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
        programs = {
          msfconsole.prependFlags = ["--defer-module-loads"];
          msfvenom.prependFlags = [];
        };
      })
    ];
  };
}
