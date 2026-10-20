{chimera, ...}: {
  # Tools every user gets, on every host.
  chimera.apps.provides.coreutils.base.homeManager = {pkgs, ...}: let
    lib = pkgs.lib;
    rgaHelpers = with pkgs; [
      ffmpeg
      poppler-utils
      ripgrep
      zip
      fzf
    ];
    ripgrepAll = pkgs.ripgrep-all.overrideAttrs (_: {
      postInstall = ''
        for bin in $out/bin/*; do
          wrapProgram "$bin" --prefix PATH ":" "${lib.makeBinPath rgaHelpers}"
        done
      '';
    });
  in {
    home.packages = with pkgs; [
      aria2
      choose
      difftastic
      dua
      edir
      fd
      fzf
      file
      hexyl
      inotify-tools
      killall
      progress
      psmisc
      python3
      ripgrep
      ripgrepAll
      rsync
      sd
      strace
      tcpdump
      traceroute
      try
      unzip
      wget
      whois
    ];
  };

  # desktop-only add-ons, see AGENTS.md
  chimera.apps.provides.coreutils.desktop = {
    includes = [chimera.apps.provides.coreutils.base];
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        doggo
        dust
        ddcutil
        eva
        ffmpeg
        gdu
        glow
        isd
        lemmeknow
        lurk
        mprocs
        (ouch.override {enableUnfree = true;})
        pciutils
        procs
        psutils
        unrar
        usbutils

        # heavy packages, commented out to reduce closure size
        # gptfdisk
        # imagemagick
        # rclone
        # stdenv
        # stdenv.cc
        # waypipe
      ];
    };
  };

  # VM variant: base plus plain ouch, dropping the 15 desktop add-ons.
  chimera.apps.provides.coreutils-slim = {
    includes = [chimera.apps.provides.coreutils.base];
    homeManager = {pkgs, ...}: {
      home.packages = [pkgs.ouch];
    };
  };
}
