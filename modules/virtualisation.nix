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
    virtualbox = {
      nixos = {
        virtualisation.virtualbox.host.enable = true;
        users.privilegedGroups = ["vboxusers"];
      };
    };
  };
}
