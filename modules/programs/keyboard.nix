{
  chimera.apps._.openrgb = {
    nixos = {
      pkgs,
      ...
    }: {
      services.openrgb.enable = true;
      environment.systemPackages = [pkgs.openrgb-with-all-plugins];
    };
  };
}
