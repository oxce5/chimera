{
  inputs,
  chimera,
  ...
}: {
  chimera.herdr = {
    nixos.nixpkgs.overlays = [inputs.herdr-nix.overlays.default];

    base.homeManager = {
      imports = [inputs.herdr-nix.homeModules.default];
      programs.herdr.enable = true;
    };

    machina-mori = {
      includes = [chimera.herdr.base];
      homeManager = {pkgs, ...}: {
        programs.herdr = {
          plugins = [pkgs.herdrPlugins.herdr-spreader];
          pluginSettings = {
            herdr-spreader = import ./_herdr-spreader.nix;
          };
        };
      };
    };
  };
}
