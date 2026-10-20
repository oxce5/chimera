{inputs, ...}: {
  # shared basics; include via the host role, not per host
  chimera.boot.nixos.boot = {
    loader.systemd-boot.enable = true;
    consoleLogLevel = 3;
  };

  chimera.boot.provides = {
    # secure.nixos = {
    #   imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];
    #   boot = {
    #     loader.systemd-boot.enable = lib.mkForce false;
    #     lanzaboote = {
    #       enable = true;
    #       pkiBundle = "/var/lib/sbctl";
    #     };
    #   };
    # };

    graphical.nixos.boot = {
      plymouth = {
        enable = true;
        theme = "tetos";
        themePackages = [inputs.chimera-pkgs.packages.x86_64-linux.plymouth-theme-tetos];
      };
      initrd.verbose = false;
      kernelParams = [
        "quiet"
        "splash"
        "intremap=on"
        "boot.shell_on_fail"
        "udev.log_priority=3"
        "rd.systemd.show_status=auto"
      ];
    };
  };
}
