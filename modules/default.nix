{
  inputs,
  __findFile,
  ...
}: {
  den.default = {
    includes = [
      <den/define-user>
      <den/hostname>
    ];

    nixos = {
      pkgs,
      lib,
      ...
    }: {
      imports = with inputs; [
        nixos-facter-modules.nixosModules.facter
      ];

      environment = {
        binsh = "${pkgs.dash}/bin/dash";
        defaultPackages = lib.mkForce [];
      };
      documentation = {
        doc.enable = false;
        info.enable = false;
        man.enable = false;
        nixos.enable = false;
      };

      i18n = {
        defaultLocale = "en_US.UTF-8";
        supportedLocales = ["en_US.UTF-8/UTF-8"];
      };

      services.dbus.implementation = "broker";
      system.stateVersion = "22.05";
      time.timeZone = "Asia/Manila";
      zramSwap.enable = true;
      home-manager = {
        useUserPackages = true;
        useGlobalPkgs = true;
      };

      nixpkgs.config.permittedInsecurePackages = [
        "electron-40.10.5"
      ];
    };
    homeManager = {
      programs.home-manager.enable = true;
      home = {
        sessionPath = ["$HOME/.local/bin"];
        stateVersion = "26.05";
      };
    };
  };
}
