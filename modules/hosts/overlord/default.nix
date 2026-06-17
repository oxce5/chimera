{
  chimera,
  config,
  inputs,
  ...
}: {
  hostConfig.overlord = {
    primaryDisplay = config.hostConfig.overlord.displays.eDP-1;
    displays = {
      eDP-1 = {
        refresh = 144.0;
        width = 1920;
        height = 1080;
        scaling = 1.00;
        wallpaper = /assets/kasane-teto-anime-art.jpg;
      };
    };
  };

  den.hosts.x86_64-linux.overlord = {inherit (config.hostConfig.overlord) displays primaryDisplay;};
  den.aspects.overlord = {
    includes = with chimera; [
      laptop
      gaming._.min
    ];

    nixos = {
      pkgs,
      config,
      ...
    }: {
      facter.reportPath = ./_facter.json;
      imports = [];

      boot = {
        kernelPackages = pkgs.linuxPackages_zen;
        loader.systemd-boot.enable = true;
        # kernelParams = ["acpi_backlight=native"];
        # binfmt.emulatedSystems = [ "aarch64-linux" ];
      };

      # networking.hostName = "chimera";
      networking.networkmanager.enable = true;


      services = {
        xserver.videoDrivers = ["nvidia"];
        # fwupd.enable = true; # Enable firmware updates with `fwupdmgr update`
      };

      hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = false;
        open = true;
        nvidiaSettings = true;
        prime = {
          offload = {
            enable = true;
            enableOffloadCmd = true;
          };
          intelBusId = "PCI:0:2:0";
          nvidiaBusId = "PCI:1:0:0";
        };
        package = config.boot.kernelPackages.nvidiaPackages.stable;
      };
      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
          libva
          intel-media-driver
          nvidia-vaapi-driver
        ];
      };

      virtualisation.docker.enable = true;
      hardware.nvidia-container-toolkit.enable = true;
    };
  };
}
