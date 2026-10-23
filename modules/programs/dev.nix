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
      includes = [chimera.dev.sessions];
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
