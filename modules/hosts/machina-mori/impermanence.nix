{...}: {
  den.aspects.machina-mori = {
    nixos = {
      # This service is pointless, we have a persistent machine-id.
      systemd.suppressedSystemUnits = ["systemd-machine-id-commit.service"];

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
      nixos.preservation.preserveAt."/persist".users.${user.userName}.directories = [
        ".config/nvim"
        ".local/state/nvim"
        ".sliver-client"
      ];
    };
  };
}
