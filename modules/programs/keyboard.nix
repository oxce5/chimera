{
  chimera.apps._.openrgb = {
    nixos = {
      pkgs,
      ...
    }: {
      services.hardware.openrgb.enable = true;
      environment.systemPackages = [pkgs.openrgb-with-all-plugins];
    };
  };
}
