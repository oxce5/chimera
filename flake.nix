{
  # flake nixConfig must stay literal; modules/cachix.nix reads these lists
  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    den.url = "github:vic/den";
    # flake-aspects.url = "github:vic/flake-aspects";

    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-facter-modules.url = "github:nix-community/nixos-facter-modules";
    wrapper-manager.url = "git+https://codeberg.org/viperML/wrapper-manager";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    preservation.url = "github:nix-community/preservation";

    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    chimera-pkgs.url = "github:oxce5/chimera-pkgs";

    herdr-nix = {
      url = "github:lorenzorapetti/herdr-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    nix-alien = {
      url = "github:thiagokokada/nix-alien";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nix-index-database.follows = "nix-index-database";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri-nix.url = "git+https://codeberg.org/bananad3v/niri-nix.git";
    niri-flake.url = "github:sodiboo/niri-flake";

    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia.url = "github:noctalia-dev/noctalia/cachix";
    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    helium = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    kopuz.url = "github:temidaradev/kopuz";
    elyprism-launcher.url = "github:elyprismlauncher/elyprismlauncher";
    dw-proton.url = "github:imaviso/dwproton-flake";
  };

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://chaotic-nyx.cachix.org"
      "https://chimera-pkgs.cachix.org"
      "https://devenv.cachix.org"
      "https://herdr-nix.cachix.org"
      "https://kopuz.cachix.org"
      "https://niri.cachix.org"
      "https://niri-nix.cachix.org"
      "https://nix-gaming.cachix.org"
      "https://noctalia.cachix.org"
      "https://prismlauncher.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
      "chimera-pkgs.cachix.org-1:gJAmxhc5yaLyHZ2ZecRA57syBgqBXYSFADvFjloxJxQ="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "herdr-nix.cachix.org-1:UpdsQYx39PK0PToKQaa2EFq19Lsjs1M9Ho+X7VNt9gs="
      "kopuz.cachix.org-1:J2X3AnAYhKTJW5S3aCLoA1ckonQXVNZMQvhZA0YAufw="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
      "niri-nix.cachix.org-1:SvFtqpDcf7Sm1SMJdby1/+Y+6f3Yt3/3PMcSTKPJNJ0="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      "prismlauncher.cachix.org-1:9/n/FGyABA2jLUVfY+DEp4hKds/rwO+SCOtbOkDzd+c="
    ];
  };

}
