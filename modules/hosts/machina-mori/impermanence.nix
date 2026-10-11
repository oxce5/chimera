{...}: {
  den.aspects.machina-mori.nixos = {lib, ...}: {
    preservation.preserveAt."/persist".directories = [
      "/var/lib/sliver"
    ];
  };
}
