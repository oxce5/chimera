{den, ...}: {
  den.default.nixos = {lib, ...}: let
    cachix = {
      chaotic-nyx = {
        url = "https://chaotic-nyx.cachix.org/";
        key = "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8=";
      };
      nix-community = {
        url = "https://nix-community.cachix.org";
        key = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
      };
      nix-gaming = {
        url = "https://nix-gaming.cachix.org";
        key = "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=";
      };
      prismlauncher = {
        url = "https://prismlauncher.cachix.org";
        key = "prismlauncher.cachix.org-1:9/n/FGyABA2jLUVfY+DEp4hKds/rwO+SCOtbOkDzd+c=";
      };
      devenv = {
        url = "https://devenv.cachix.org";
        key = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
      };
      niri = {
        url = "https://niri.cachix.org";
        key = "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964=";
      };
      kopuz = {
        url = "https://kopuz.cachix.org";
        key = "kopuz.cachix.org-1:J2X3AnAYhKTJW5S3aCLoA1ckonQXVNZMQvhZA0YAufw=";
      };
      helix = {
        url = "https://helix.cachix.org";
        key = "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs=";
      };
      adithyagenie = {
        url = "https://adithyagenie.cachix.org";
        key = "adithyagenie.cachix.org-1:h6BSMboeVfxyrULWuRQqAyweo4AJRATekb88xotfQwc=";
      };
    };
  in {
    nix.settings = {
      extra-substituters = lib.mapAttrsToList (_: v: v.url) cachix;
      extra-trusted-public-keys = lib.mapAttrsToList (_: v: v.key) cachix;
    };
  };
}
