{inputs, ...}: {
  den.aspects.overlord.nixos = {
    imports = [
      inputs.disko.nixosModules.disko
      ./_disk-layout.nix
    ];

    fileSystems = {
      "/home".neededForBoot = true;
      "/persist".neededForBoot = true;
      "/nix".neededForBoot = true;
    };
  };
}
