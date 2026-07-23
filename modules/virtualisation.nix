{chimera, ...}: {
  chimera.virt.provides = {
    qemu = {
      nixos = {pkgs, ...}: {
        users.privilegedGroups = ["kvm"];
        networking.firewall.trustedInterfaces = ["virbr0"];
        programs.virt-manager.enable = true;
        environment.systemPackages = with pkgs; [
          virglrenderer
        ];
        services.qemuGuest.enable = true;
        virtualisation = {
          libvirtd.enable = true;
          spiceUSBRedirection.enable = true;
        };
      };
    };
  };
}
