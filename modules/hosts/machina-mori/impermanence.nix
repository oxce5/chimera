{...}: {
  den.aspects.machina-mori.nixos = {
    preservation.preserveAt."/persist".directories = [
      "/opt"
      "/var/lib/sliver"
      "/workspace"
    ];
  };
}
