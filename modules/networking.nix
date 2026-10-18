{
  chimera.networking = {
    # provides.wol.nixos.systemd.network.links."10-wol" = {
    #   matchConfig.Type = "ether";
    #   linkConfig.WakeOnLan = "magic";
    # };
    nixos = {
      networking = {
        networkmanager.enable = true;
        nftables.enable = true;
        wireguard.enable = true;
        firewall.trustedInterfaces = [
          "virbr0"
          "podman0"
          "docker0"
        ];
        resolvconf.extraOptions = ["timeout:1" "attempts:2"];
      };
      services.dnsmasq = {
        enable = true;
        resolveLocalQueries = true;
        settings = {
          listen-address = "127.0.0.1";
          bind-interfaces = true;
          no-resolv = true;
          strict-order = true;
          cache-size = 10000;

          server = [
            "/chimera.moe/100.97.28.65"
            "/chimera.moe/192.168.1.21"

            "100.97.28.65"
            "192.168.1.21"
          ];
        };
      };
    };
  };
}
