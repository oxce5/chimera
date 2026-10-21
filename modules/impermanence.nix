{inputs, ...}: {
  chimera.impermanence.provides = {
    tmp.nixos = {
      fileSystems."/tmp" = {
        device = "tmpfs";
        fsType = "tmpfs";
        options = [
          "mode=1777"
          "size=100%"
        ];
      };
      fileSystems."/var/tmp" = {
        device = "tmpfs";
        fsType = "tmpfs";
        options = [
          "mode=1777"
          "size=100%"
        ];
      };
    };
    root.nixos = {
      imports = [inputs.preservation.nixosModules.default];

      preservation = {
        enable = true;

        preserveAt."/persist" = {
          files = [
            {
              file = "/etc/machine-id";
              inInitrd = true;
            }
            {
              file = "/etc/ssh/ssh_host_ed25519_key";
              how = "symlink";
              configureParent = true;
            }
            {
              file = "/etc/ssh/ssh_host_rsa_key";
              how = "symlink";
              configureParent = true;
            }
            {
              file = "/var/lib/systemd/random-seed";
              how = "symlink";
              inInitrd = true;
              configureParent = true;
            }
          ];

          directories = [
            "/var/lib/NetworkManager"
          ];
        };
      };
    };
  };
}
