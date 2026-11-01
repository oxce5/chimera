{...}: {
  chimera.nvf.ui = {
    homeManager = {lib, ...}: {
      programs.nvf.settings.vim = {
        ui = {
          borders.enable = true;
          noice.enable = true;
          noice.setupOpts = {
            presets.inc_rename = true;
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
            views = {
              cmdline_popup = {
                border = {
                  style = "rounded";
                  padding = [0 2];
                };
                win_options.winhighlight = {
                  Normal = "Normal";
                  FloatBorder = "FloatBorder";
                  FloatTitle = "FloatTitle";
                  Border = "FloatBorder";
                };
              };
              notify = {
                border = {style = "rounded";};
                win_options.winhighlight = {
                  Normal = "Normal";
                  FloatBorder = "FloatBorder";
                  FloatTitle = "FloatTitle";
                  Border = "FloatBorder";
                };
              };
              cmdline = {
                border = {
                  style = "none";
                  padding = [0 0];
                };
              };
            };
          };
        };
      };
    };
  };
}
