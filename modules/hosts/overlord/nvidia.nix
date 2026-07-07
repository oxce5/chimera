{
  den.aspects.overlord.nixos = {
    pkgs,
    config,
    ...
  }: {
    services.xserver.videoDrivers = ["nvidia"];
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
  };
}
