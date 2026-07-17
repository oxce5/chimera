{den, ...}: {
  den.default.nixos = {lib, ...}: let
    mkCachix = name: key: {
      url = "https://${name}.cachix.org";
      inherit key;
    };
    cachix = {
      chaotic-nyx    = mkCachix "chaotic-nyx" "HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8=";
      nix-community  = mkCachix "nix-community" "mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
      nix-gaming     = mkCachix "nix-gaming" "nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=";
      prismlauncher  = mkCachix "prismlauncher" "9/n/FGyABA2jLUVfY+DEp4hKds/rwO+SCOtbOkDzd+c=";
      devenv         = mkCachix "devenv" "w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
      niri           = mkCachix "niri" "Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964=";
      kopuz          = mkCachix "kopuz" "J2X3AnAYhKTJW5S3aCLoA1ckonQXVNZMQvhZA0YAufw=";
    };
  in {
    nix.settings = {
      extra-substituters = lib.mapAttrsToList (_: v: v.url) cachix;
      extra-trusted-public-keys = lib.mapAttrsToList (_: v: v.key) cachix;
    };
  };
};
