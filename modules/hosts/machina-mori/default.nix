{
  chimera,
  lib,
  ...
}: {
  den.aspects.machina-mori = {
    includes = with chimera; [
      vm
      virt._.guest
    ];
  };

  den.hosts.x86_64-linux.machina-mori = {
    displays.Virtual-1 = {
      # The QEMU monitor only advertises the modes its firmware provides, and
      # 1888x980 is not one of them -- niri silently falls back to the
      # preferred 1280x800 unless the mode is requested as custom.
      width = 1888;
      height = 980;
      custom = true;
      refresh = 60.0;
      wallpaper = "/assets/rei.jpeg";
    };
  };

  den.aspects.machina-mori.nixos = {
    users.privilegedGroups = ["audio" "video" "render"];

    services = {
      openssh.enable = true;

      greetd = {
        enable = true;
        restart = false;
        settings = {
          default_session = {
            command = "niri-session";
            user = "rei";
          };
        };
      };
    };

    # Docker is part of the pwn toolchain, but there is no use for it inside
    # the VM itself.
    virtualisation.docker.enable = lib.mkForce false;
  };
}
