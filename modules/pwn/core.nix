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
      # lists = [nmap]: seclists is ~2 GiB, rest is opt-in
      wordlists = pkgs.wordlists.override {
        lists = [pkgs.nmap];
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

  # opt in per host/user via <chimera/pwn/wordlists>
  chimera.pwn.provides.wordlists.homeManager = {pkgs, ...}: {
    home.packages = [
      (pkgs.wordlists.override {
        lists = with pkgs; [
          rockyou
          seclists
          wfuzz
        ];
      })
    ];
  };
}
