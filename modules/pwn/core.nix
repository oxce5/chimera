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
      # nixpkgs' default is [nmap rockyou seclists wfuzz]. `rockyou` is now cut
      # from seclists upstream, so keeping it costs the full ~2 GiB seclists
      # tree. nmap's lists are small; the rest is opt-in via
      # chimera.pwn.provides.wordlists.
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

  # The big lists (rockyou + seclists ~2 GiB, wfuzz) are not part of chimera.pwn
  # by default. Opt in per host/user, e.g. in modules/users/rei.nix:
  #   den.aspects.rei.includes = [ <chimera/pwn/wordlists> ];
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
