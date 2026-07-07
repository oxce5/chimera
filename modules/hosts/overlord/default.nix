{
chimera,
config,
inputs,
den,
lib,
__findFile,
...
}:
let
  inherit (den.lib.policy) include;
in {
  den.aspects.overlord.policies.to-users = { host, user, ... }: [
    (include {
      includes = lib.optionals (user.userName == "oxce5") [ 
        <chimera/laptop>
        <chimera/gaming/max>
      ];
    })
  ];

  den.aspects.overlord.includes = [
    den.aspects.overlord.policies.to-users
  ];

  den.aspects.overlord.nixos = { pkgs, config, ... }: {
    facter.reportPath = ./_facter.json;
    boot = {
      kernelPackages = pkgs.linuxPackages_zen;
      loader.systemd-boot.enable = true;
    };
    networking.networkmanager.enable = true;
    virtualisation.docker.enable = true;
    hardware.nvidia-container-toolkit.enable = true;

    nix.settings = {
      extra-substituters = [
        "https://chaotic-nyx.cachix.org/"
        "https://nix-community.cachix.org"
        "https://nix-gaming.cachix.org"
        "https://prismlauncher.cachix.org"
        "https://devenv.cachix.org"
        "https://niri.cachix.org"
        "https://kopuz.cachix.org"
        "https://helix.cachix.org"
      ];
      extra-trusted-public-keys = [
        "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
        "prismlauncher.cachix.org-1:9/n/FGyABA2jLUVfY+DEp4hKds/rwO+SCOtbOkDzd+c="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
        "adithyagenie.cachix.org-1:h6BSMboeVfxyrULWuRQqAyweo4AJRATekb88xotfQwc="
        "kopuz.cachix.org-1:J2X3AnAYhKTJW5S3aCLoA1ckonQXVNZMQvhZA0YAufw="
        "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
      ];
    };
  };
}
