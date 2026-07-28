{chimera, ...}: {
  chimera.virt.provides = {
    host = {
      nixos = {pkgs, ...}: {
        users.privilegedGroups = ["kvm"];
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
    guest.nixos = {
      services = {
        qemuGuest.enable = true;
        spice-vdagentd.enable = true;
      };
    };
    docker = {
      nixos = {
        virtualisation.docker = {
          enable = true;
        };
      };
    };
  };
}
