{
  inputs,
  den,
  lib,
  __findFile,
  ...
}: {
  # Some preferred defaults
  den = {
    schema.user = {
      classes = lib.mkDefault [ "homeManager" ];

      # host<->user provides
      # includes = [ den._.mutual-provider ];
    };

    default = {
      includes = [
        <den/define-user>
        (
          {host, ...}: {
            ${host.class}.networking.hostName = host.name;
          }
        )
      ];

      nixos = {
        pkgs,
        lib,
        ...
      }: {
        imports = with inputs; [
          nixos-facter-modules.nixosModules.facter
          home-manager.nixosModules.home-manager
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
      };
      homeManager = {
        programs.home-manager.enable = true;
        home = {
          sessionPath = ["$HOME/.local/bin"];
          stateVersion = "22.05";
        };
      };
    };
  };
}
