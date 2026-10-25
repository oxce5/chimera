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
      homeManager = {
        programs.opencode = {
          enable = true;
        };
      };
      mcp.homeManager = {pkgs, ...}: {
        programs.mcp = {
          enable = true;
          servers.nixos = {
            command = "${pkgs.mcp-nixos}/bin/mcp-nixos";

          };
        };

        programs.opencode.enableMcpIntegration = true;
      };
    };
  };
}
