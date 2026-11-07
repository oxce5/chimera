{
  den.aspects.overlord.nixos = {
    pkgs,
    config,
    ...
  }: {
    services.xserver.videoDrivers = ["nvidia"];
    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
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

    boot.kernelParams = ["nvidia.NVreg_PreserveVideoMemoryAllocations=1" "nvidia.NVreg_TemporaryFilePath=/var/tmp"];
    systemd.services.nvidia-persistenced = {
      enable = true;
      wantedBy = ["multi-user.target"];
    };
    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        libva
        intel-media-driver
        nvidia-vaapi-driver
      ];
    };
  };
}
