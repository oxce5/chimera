{chimera, ...}: {
  chimera.dev.provides = {
    base.homeManager.programs.uv.enable = true;
    min = {
      homeManager = {pkgs, ...}: {
        home.packages = with pkgs; [
          devenv
        ];
      };
    };
    ai = {
      includes = [chimera.dev._.sessions];
      homeManager = {
        programs.opencode = {
          enable = true;
        };
      };
    };
    sessions = {
      homeManager = {
        programs.herdr.enable = true;
      };
    };
  };
}
