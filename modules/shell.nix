{
  chimera.shell.homeManager = {
    pkgs,
    config,
    ...
  }: {
    programs = {
      bash = {
        enable = true;
        enableVteIntegration = true;
        historyFile = "${config.xdg.configHome}/bash/history";
      };
      starship = {
        enable = true;
        settings = {
          format = "$all";
          character = {
            success_symbol = "[➜](bold green)";
            error_symbol = "[➜](maroon)";
          };
          shell.disabled = false;
          jobs.disabled = true; # TODO atuin creates a job during the prompt closure and the symbol_threshold option is bugged
          # Jujutsu - https://github.com/jj-vcs/jj/wiki/Starship
          git_branch.disabled = true;
          git_commit.disabled = true;
          git_state.disabled = true;
          git_metrics.disabled = true;
          git_status.disabled = true;
        };
      };
      atuin = {
        enable = true;
        flags = ["--disable-up-arrow"];
      };
      bat = {
        enable = true;
        config.style = "plain";
        extraPackages = with pkgs.bat-extras; [
          prettybat
          batwatch
          batpipe
          batman
          # batgrep
          batdiff
        ];
      };
      bottom.enable = true;
      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
      eza = {
        enable = true;
        git = true;
        icons = "auto";
        enableNushellIntegration = false;
      };
      nix-your-shell = {
        enable = true;
        enableFishIntegration = true;
        nix-output-monitor.enable = true;
      };
      skim.enable = true;
      tealdeer = {
        enable = true;
        settings.updates.auto_update = true;
      };
      yazi = {
        enable = true;
        shellWrapperName = "y";
      };
      zoxide.enable = true;
    };
  };
}
