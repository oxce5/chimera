{...}: {
  den.aspects.machina-mori = {
    nixos = {
      preservation.preserveAt."/persist".directories = [
        {
          directory = "/opt";
          user = "rei";
          group = "users";
        }
        {
          directory = "/var/lib/sliver";
          user = "sliver";
        }
        {
          directory = "/workspace";
          user = "rei";
          group = "users";
        }
      ];
    };

    provides.to-users = {user, ...}: {
      nixos.preservation.preserveAt."/persist".users.${user.userName} = {
        directories = [
          ".cache/awww"
          ".config/carapace"
          ".config/kitty"
          ".config/mozilla"
          ".config/net.imput.helium"
          ".config/nuclei"
          ".config/nvim"
          ".config/uncover"
          ".config/vicinae"
          ".local/share/atuin"
          ".local/share/fish"
          ".local/share/nvim"
          ".local/share/vicinae"
          ".local/share/zoxide"
          ".local/state/nvim"
          ".msf4"
          ".penelope"
          ".sliver-client"
          "nuclei-templates"
          ".config/herdr/plugins"
        ];
        files = [
          ".config/herdr/config.toml"
          ".config/herdr/session.json"
        ];
      };
    };
  };
}
