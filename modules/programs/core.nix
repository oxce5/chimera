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
      ouch
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
}
