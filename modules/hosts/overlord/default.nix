{chimera, ...}: {
  den.aspects.overlord = {
    includes = with chimera; [
      laptop
      apps._.openrgb
      virt._.host
      virt._.docker
    ];
  };

  den.hosts.x86_64-linux.overlord = {
    # Keys are output names, copied from `niri msg outputs`; this one needs
    # quoting because it is not a plain connector name.
    #
    # Pinned panel; HDMI-A-5 is the projector
    # mode deliberately unpinned.
    displays = {
      eDP-1 = {
        primary = true;
        width = 1920;
        height = 1080;
        refresh = 60.0;
        x = 1080;
        y = 640;
      };
      HDMI-A-5 = {
        width = 1920;
        height = 1080;
      };
      "Dell Inc. DELL P2317H 226H172O249S" = {
        width = 1920;
        height = 1080;
        refresh = 60.0;
        transform = "270";
      };
    };
  };

  den.aspects.overlord.nixos = {
    pkgs,
    config,
    ...
  }: {
    facter.reportPath = ./_facter.json;
    boot = {
      kernelPackages = pkgs.linuxPackages_zen;
      # /dev/fuse, for the rclone mount in <chimera/storage>.
      kernelModules = ["fuse"];
    };
    networking = {
      hosts = {
        "192.168.1.254" = ["bastion"];
      };
    };

    users.privilegedGroups = ["audio" "docker"];
    hardware.nvidia-container-toolkit.enable = true;
  };
}
