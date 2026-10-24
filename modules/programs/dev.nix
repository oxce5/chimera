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
    };
  };
}
