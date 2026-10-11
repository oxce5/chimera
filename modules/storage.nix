{
  chimera.storage.homeManager = {
    config,
    lib,
    pkgs,
    ...
  }: {
    programs.rclone = {
      enable = true;

      remotes.copyparty = {
        config = {
          type = "sftp";
          host = "copyparty.chimera.moe";
          port = 3922;
          user = "admin";
          known_hosts_file = "${config.home.homeDirectory}/.ssh/known_hosts";
        };

        mounts."/admin/Blender" = {
          enable = true;
          mountPoint = "${config.home.homeDirectory}/Blender_online";
          options = {
            vfs-cache-mode = "full";
            vfs-cache-max-size = "10G";
            vfs-cache-max-age = "24h";
            dir-cache-time = "1m";
            timeout = "60s";
            contimeout = "10s";
            low-level-retries = 3;
          };
        };
      };
    };

    systemd.user.services."rclone-mount:.admin.Blender@copyparty" = {
      Service = {
        Type = lib.mkForce "exec";
        RestartSec = "30s";
        TimeoutStopSec = "30s";
        ExecStopPost = "-${pkgs.fuse3}/bin/fusermount3 -uz %h/Blender_online";
      };
      Unit.StartLimitIntervalSec = "5min";
    };
  };
}
