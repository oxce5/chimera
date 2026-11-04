{...}: {
  chimera.nvf.ui = {
    homeManager = {lib, ...}: {
      programs.nvf.settings.vim = {
        ui = {
          borders.enable = true;
          noice.enable = true;
          noice.setupOpts = {
            presets.inc_rename = true;
            # fidget owns LSP progress, keep noice from overlaying it
            lsp.progress.enabled = false;
            cmdline.view = "cmdline_popup";
            messages.view = "notify";
            popupmenu = {
              backend = "nui";
              position = "cursor";
              size = {
                width = 40;
                height = 10;
              };
            };
          };
        };
      };
    };
  };
}
