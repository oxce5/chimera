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
      width = 1888;
      height = 980;
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
