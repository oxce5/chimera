{inputs, ...}: {
  perSystem = {
    system,
    ...
  }: {
    packages.nixos-anywhere =
      (inputs.nixos-anywhere.packages.${system}.nixos-anywhere).overrideAttrs (o: {
        patches =
          (o.patches or [ ])
          ++ [ ../patches/nixos-anywhere-dash-ssh-copy-id.patch ];
      });
  };
}
