{chimera, ...}: {
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
            command = "${pkgs.mcp-nixos.override {
              python3Packages = pkgs.python3Packages.overrideScope (pyFinal: pyPrev: {
                fastmcp-slim = pyPrev.fastmcp-slim.override {mcp = pyFinal.mcp_1;};
              });
            }}/bin/mcp-nixos";
          };
        };

        programs.opencode.enableMcpIntegration = true;
      };
    };
  };
}
