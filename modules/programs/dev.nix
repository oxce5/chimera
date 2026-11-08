{
  inputs,
  chimera,
  ...
}: {
  chimera.dev = {
    base.homeManager.programs.uv.enable = true;
    min = {
      homeManager = {pkgs, ...}: {
        home.packages = with pkgs; [
          devenv
        ];
      };
    };
    ai = {
      homeManager = {pkgs, ...}: {
        programs.opencode = {
          enable = true;
          package = pkgs.opencode.overrideAttrs (old: {
            node_modules = old.node_modules.overrideAttrs (_: {
              outputHash = "sha256-prx9dX7kUvs/E3zopkaPk5LXh3xJAy5sZeum/W8L7cA=";
            });
          });
        };
      };
      mcp.homeManager = {pkgs, ...}: {
        programs.mcp = {
          enable = true;
          servers.nixos = {
            command = "${inputs.mcp-nixos.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/mcp-nixos";
          };
        };

        programs.opencode.enableMcpIntegration = true;
      };
    };
  };
}
