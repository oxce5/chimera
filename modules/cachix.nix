{den, ...}: let
  inherit (import ../flake.nix) nixConfig;
in {
  den.default.nixos = {...}: {
    nix.settings = {
      inherit (nixConfig) extra-substituters extra-trusted-public-keys;
    };
  };
}
