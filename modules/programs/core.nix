{chimera, ...}: {
  # Tools every user gets, on every host.
  chimera.apps.provides.coreutils.base.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [
      aria2
      choose
      difftastic
      dua
      edir
      fd
      file
      hexyl
      inotify-tools
      killall
      progress
      psmisc
      python3
      ripgrep
      ripgrep-all
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

  # Desktop add-ons on top of the base: the bigger/duplicate CLIs that only
  # earn their closure cost on the laptop.
  chimera.apps.provides.coreutils.desktop = {
    includes = [chimera.apps.provides.coreutils.base];
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        doggo
        dust
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
