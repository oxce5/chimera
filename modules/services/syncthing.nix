{chimera, ...}: {
  chimera.services._.syncthing = {
    homeManager.services.syncthing = {
      enable = true;
      settings = {
        devices = {
          overlord = {
            id = "RLH5I5F-DO4BWMI-OEE5LA2-R5ESJVF-3ASNLA3-LOLCZBD-W7BVLIK-5QMFUAJ";
            autoAcceptFolders = true;
          };
          # rei = {
          #   id = "";
          #   autoAcceptFolders = true;
          # };
          server = {
            id = "HPI5A3Y-3WVQCUJ-JCAWJG7-D7YT7N5-IWVAMDQ-Z66TLFY-2JSZHCG-EBWR7QI";
            autoAcceptFolders = true;
          };
          phone = {
            id = "4XHVIG5-GR625VO-PHTI54T-ILKGW4Z-J6HHNWI-UYUEZBB-TYF6E4R-FQGQHAI";
            autoAcceptFolders = true;
          };
        };
        folders = {
          "~/Projects" = {
            id = "projects";
            devices = [
              "overlord"
              "server"
              # "rei"
            ];
          };
          "~/Music" = {
            id = "music";
            devices = [
              "overlord"
              "server"
              "phone"
            ];
          };
        };
      };
    };
  };
}
