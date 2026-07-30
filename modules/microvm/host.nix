{ inputs, ... }:
{
  chimera.microvm.provides.host.nixos = { pkgs, ... }: {
    imports = [ inputs.microvm.nixosModules.host ];

    systemd.network.networks."10-machina-mori" = {
      matchConfig.Name = "vm-mori";
      address = [ "10.4.4.1/30" ];
      networkConfig.IPv4Forwarding = true;
    };

    networking.nftables.ruleset = ''
      table ip nat {
        chain postrouting {
          type nat hook postrouting priority srcnat; policy accept;
          ip saddr 10.4.4.0/30 masquerade
        }
      }
    '';

    environment.systemPackages = with pkgs; [ spice-gtk ];
  };
}
