{
  chimera.tailscale.nixos.services.tailscale = {
    enable = true;
    openFirewall = true;
    extraSetFlags = ["--accept-dns=false"];
  };
}
