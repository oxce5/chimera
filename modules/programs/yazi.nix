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
          open.prepend_rules =
            map (mime: {
              inherit mime;
              use = "extract";
            }) [
              "application/zip"
              "application/x-tar"
              "application/gzip"
              "application/x-bzip-compressed-tar"
              "application/x-xz-compressed-tar"
            ];
          plugin.prepend_previewers =
            map (mime: {
              inherit mime;
              run = "ouch";
            }) [
              "application/zip"
              "application/x-tar"
              "application/x-bzip2"
              "application/x-7z-compressed"
              "application/x-rar"
              "application/x-xz"
              "application/xz"
              "application/x-zstd"
              "application/zstd"
              "application/java-archive"
            ];
        };
      };
    };
  };
}
