{...}: {
  den.aspects.overlord = {
    nixos = {
      preservation.preserveAt."/persist" = {
        directories = [
          {
            directory = "/etc/NetworkManager/system-connections";
            mode = "0700";
            configureParent = true;
          }
          "/var/lib/AccountsService"
          "/var/lib/bluetooth"
          "/var/lib/cups"
          "/var/lib/docker"
          "/var/lib/flatpak"
          "/var/lib/libvirt"
          "/var/lib/nixos"
          {
            directory = "/var/lib/tailscale";
            mode = "0700";
          }
          "/var/lib/waydroid"
        ];

        users.oxce5 = {
          directories = [
            {
              directory = ".ssh";
              mode = "0700";
            }
            {
              directory = ".docker";
              mode = "0700";
            }
            {
              directory = ".pki";
              mode = "0700";
            }
            {
              directory = ".local/share";
              mode = "0700";
            }
            {
              directory = ".local/state";
              mode = "0700";
            }
            {
              directory = "share";
              mode = "0700";
            }

            ".config"
            ".local/bin"
            ".mozilla"
            ".var"
            ".dskmatewine"

            "Projects"
            "Documents"
            "Pictures"
            "Music"
            "Hacking"
            "backups"
            "marked_for_backup"
            "Desktop"
            "characters"
            ".barony"
            "Blender"
            "Games"
            "llama"
          ];

          files = [
            {
              file = ".bash_history";
              mode = "0600";
            }
            {
              file = ".mycli-history";
              mode = "0600";
            }

            ".myclirc"
            ".face"
          ];
        };
      };
    };
  };
}
