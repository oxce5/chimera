{chimera, ...}: {
  chimera.virt.provides = {
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
      # Host user's public key. Trusted by default on all guests so the host
      # user can ssh in as root or any user. Replace the placeholder with
      # the real key; per-host overrides remain possible via mkDefault.
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

    # A throwaway VM: no speech daemon, no prebuilt nix-index database, no
    # avahi/printing, and a short bootloader timeout. The laptop keeps the
    # upstream defaults for all of these.
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

      hardware.enableRedistributableFirmware = false;

      services = {
        speechd.enable = lib.mkForce false; # only ever enabled by graphical-desktop's mkDefault
        avahi.enable = false;
        printing.enable = false;
        acpid.enable = true;
      };

      programs.nix-index-database.comma.enable = lib.mkForce false;
      programs.nix-index.package = lib.mkForce pkgs.nix-index; # drop the prebuilt ~180 MB database
    };

    # Keep the store from filling / on big nixpkgs updates. The VM only runs
    # for a few hours, so GC-on-boot catches the previous session's garbage;
    # min-free/max-free additionally auto-GC mid-build when space runs low.
    ephemeral-store.nixos = {lib, ...}: {
      nix = {
        optimise.automatic = lib.mkForce true;
        gc = {
          automatic = true;
          options = "--delete-older-than 14d --max-freed 20G";
        };
        settings = {
          keep-outputs = lib.mkForce false;
          keep-derivations = lib.mkForce false;
          auto-optimise-store = lib.mkForce false;
          min-free = "2G";
          max-free = "10G";
        };
      };
      # Run the GC unit once at boot instead of relying on a daily timer that
      # likely never fires within the VM's short uptime.
      systemd.services."nix-gc".wantedBy = lib.mkForce ["multi-user.target"];
    };

    # No sound hardware is routed to this VM, so drop the ALSA/JACK stacks.
    audio-minimal.nixos = {lib, ...}: {
      services.pipewire = {
        alsa.enable = lib.mkForce false;
        alsa.support32Bit = lib.mkForce false;
        jack.enable = lib.mkForce false;
      };
    };

    # Emoji coverage on top of the fleet-wide iosevka-chimera (contributed by
    # chimera.theming), without the rest of the default font packages (~170 MB
    # of CJK/unifont).
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
