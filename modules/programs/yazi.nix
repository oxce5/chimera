{
  chimera.apps._.yazi.homeManager = {
    pkgs,
    config,
    ...
  }: {
    programs = {
      yazi = {
        package = pkgs.yazi;
        shellWrapperName = "y";
        enable = true;
        settings = {
          mgr.prepend_keymap = [
            {
              on = ["C"];
              run = "plugin ouch";
              desc = "Compress with ouch";
            }
          ];
          opener = {
            extract = [
              {
                run = "ouch d -y \"%*\"";
                desc = "Extract here with ouch";
                for = "windows";
              }
              {
                run = "ouch d -y \"$@\"";
                desc = "Extract here with ouch";
                for = "unix";
              }
            ];
          };
          open = {
            prepend_rules = [
              {
                mime = "application/zip";
                use = "extract";
              }
              {
                mime = "application/x-tar";
                use = "extract";
              }
              {
                mime = "application/gzip";
                use = "extract";
              }
              {
                mime = "application/x-bzip-compressed-tar";
                use = "extract";
              }
              {
                mime = "application/x-xz-compressed-tar";
                use = "extract";
              }
            ];
          };
          plugin = {
            prepend_previewers = [
              {
                mime = "application/zip";
                run = "ouch";
              }
              {
                mime = "application/x-tar";
                run = "ouch";
              }
              {
                mime = "application/x-bzip2";
                run = "ouch";
              }
              {
                mime = "application/x-7z-compressed";
                run = "ouch";
              }
              {
                mime = "application/x-rar";
                run = "ouch";
              }
              {
                mime = "application/x-xz";
                run = "ouch";
              }
              {
                mime = "application/xz";
                run = "ouch";
              }
              {
                mime = "application/x-zstd";
                run = "ouch";
              }
              {
                mime = "application/zstd";
                run = "ouch";
              }
              {
                mime = "application/java-archive";
                run = "ouch";
              }
            ];
          };
        };
      };
    };
  };
}
