{inputs, ...}: {
  den.default = {
    nixos = {
      nixpkgs.config.allowUnfree = true;
      programs.nix-ld.enable = true;
      nix = {
        optimise.automatic = false;
        registry.nixpkgs.flake = inputs.nixpkgs;
        gc.automatic = true;
        settings = {
          experimental-features = ["nix-command" "flakes"];
          keep-outputs = true;
          keep-derivations = true;
          use-xdg-base-directories = true;
          auto-optimise-store = true;
          trusted-users = ["@wheel"];
        };
      };
    };
    # homeManager.nix.registry = {
    #   quix = {
    #     exact = true;
    #     from = {
    #       id = "quix";
    #       type = "indirect";
    #     };
    #     to = {
    #       type = "git";
    #       url = "";
    #     };
    #   };
    # };
  };
}
