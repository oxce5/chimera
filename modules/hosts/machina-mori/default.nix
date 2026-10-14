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

  den.aspects.machina-mori = {
    nixos = {
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

    provides.to-users = {user, ...}: {
      homeManager.programs.fish.functions.vpn = {
        description = "fzf picker for OpenVPN configs";
        body = ''
          set -l cfg (find /workspace/VPNs -type f -name '*.ovpn' | sort | \
              fzf --prompt='vpn> ' --height=40% --reverse \
                  --delimiter=/ --with-nth=-1 \
                  --preview 'grep -E "^(remote|proto|dev) " {}')

          test -n "$cfg"; or return 1
          sudo openvpn --config $cfg $argv
        '';
      };
    };
  };
}
