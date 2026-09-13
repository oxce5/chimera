{
  chimera.apps._.coreutils.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [
      aria2
      choose
      difftastic
      doggo
      dua
      dust
      edir
      eva
      fd
      file
      gdu
      glow
      hexyl
      inotify-tools
      isd
      killall
      lemmeknow
      lurk
      mprocs
      (ouch.override {enableUnfree = true;})
      pciutils
      procs
      progress
      psmisc
      psutils
      python3
      ripgrep
      ripgrep-all
      rsync
      sd
      strace
      # systeroid # TODO
      tcpdump
      traceroute
      try
      unrar
      unzip
      usbutils
      wget
      whois

      # heavy packages, commented out to reduce closure size
      # ffmpeg
      # gptfdisk
      # imagemagick
      # rclone
      # stdenv
      # stdenv.cc
      # waypipe
    ];
  };

  # VM variant: drops the 14 extra/duplicate/desktop tools
  # (dust gdu doggo unrar pciutils usbutils glow procs lemmeknow isd eva mprocs lurk psutils)
  # which are kept on the desktop via the full coreutils aspect.
  chimera.apps.provides.coreutils-slim.homeManager = {pkgs, ...}: {
    home.packages = with pkgs; [
      aria2
      choose
      difftastic
      dua
      fd
      file
      hexyl
      inotify-tools
      killall
      ouch
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
      edir
      progress
      unzip
      wget
      whois
    ];
  };
}
