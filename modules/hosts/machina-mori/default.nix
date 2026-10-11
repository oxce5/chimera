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
    virtualisation.docker.enable = lib.mkForce false;
  };
}
