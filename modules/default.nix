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
      documentation.doc.enable = false;
      documentation.info.enable = false;
      i18n.defaultLocale = "en_US.UTF-8";
      i18n.supportedLocales = ["all"];
      services.dbus.implementation = "broker";
      system.stateVersion = "22.05";
      time.timeZone = "Asia/Manila";
      zramSwap.enable = true;
      home-manager.useUserPackages = true;
      home-manager.useGlobalPkgs = true;
      boot.initrd.systemd.enable = true;
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
