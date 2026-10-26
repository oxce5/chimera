{chimera, ...}: {
  chimera.virt = {
    host = {
      nixos = {pkgs, ...}: {
        users.privilegedGroups = ["libvirtd" "kvm"];
        networking.firewall.trustedInterfaces = ["virbr0"];
        programs.virt-manager.enable = true;
        environment.systemPackages = with pkgs; [
          virglrenderer
        ];
        virtualisation = {
          libvirtd.enable = true;
          spiceUSBRedirection.enable = true;
        };
      };
    };
    guest = let
      # placeholder: trusted on all guests, override per host with mkDefault
      hostUserKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINAKxO4GG+Su881n6GAH2Evuo3BMaUlT3dHcWfiP87IR oxce5@overlord";
    in {
      nixos = {lib, ...}: {
        services = {
          qemuGuest.enable = true;
          spice-vdagentd.enable = true;
        };
        users.users.root.openssh.authorizedKeys.keys = lib.mkDefault [hostUserKey];
      };
      provides.to-users = {user, ...}: {
        nixos = {lib, ...}: {
          users.users.${user.userName}.openssh.authorizedKeys.keys = lib.mkDefault [hostUserKey];
        };
      };
    };
    docker = {
      nixos = {
        virtualisation.docker = {
          enable = true;
        };
      };
    };

    headless.nixos = {
      pkgs,
      lib,
      ...
    }: {
      boot = {
        kernelParams = ["reboot=acpi"];
        plymouth.enable = lib.mkForce false;
        loader.timeout = 5;
      };

      # capped due to low RAM
      fileSystems = {
        "/tmp" = lib.mkForce {
          device = "tmpfs";
          fsType = "tmpfs";
          options = [
            "mode=1777"
            "size=1G"
          ];
        };
        "/var/tmp" = lib.mkForce {
          device = "tmpfs";
          fsType = "tmpfs";
          options = [
            "mode=1777"
            "size=256M"
          ];
        };
      };

      hardware.enableRedistributableFirmware = false;

      services = {
        speechd.enable = lib.mkForce false; # only ever enabled by graphical-desktop's mkDefault
        avahi.enable = false;
        printing.enable = false;
        acpid.enable = true;
      };

      # just use termfilechooser bro
      xdg.portal.extraPortals = lib.mkForce (with pkgs; [
        xdg-desktop-portal-termfilechooser
      ]);
    };

    headless.homeManager = {pkgs, ...}: {
      wayland.windowManager.niri.portalPackage = pkgs.xdg-desktop-portal-termfilechooser;
    };

    ephemeral-store.nixos = {lib, ...}: {
      nix = {
        optimise.automatic = lib.mkForce true;
        gc = {
          automatic = true;
          options = "--delete-older-than 3d --max-freed 20G";
        };
        settings = {
          keep-outputs = lib.mkForce false;
          keep-derivations = lib.mkForce false;
          auto-optimise-store = lib.mkForce false;
          min-free = "2G";
          max-free = "10G";
        };
      };
      systemd.services."nix-gc".wantedBy = lib.mkForce ["multi-user.target"];
    };

    audio-minimal.nixos = {lib, ...}: {
      services.pipewire = {
        alsa.enable = lib.mkForce false;
        alsa.support32Bit = lib.mkForce false;
        jack.enable = lib.mkForce false;
      };
    };

    emoji-fonts.nixos = {
      pkgs,
      lib,
      ...
    }: {
      fonts = {
        enableDefaultPackages = lib.mkForce false;
        packages = [pkgs.noto-fonts-color-emoji];
      };
    };
  };
}
