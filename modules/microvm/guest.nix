{ inputs, lib, ... }:
{
  chimera.microvm.provides.guest.nixos = { pkgs, ... }: {
    imports = [ inputs.microvm.nixosModules.guest ];

    microvm = {
      id = 1;
      hypervisor = "qemu";
      interfaces = [{
        type = "tap";
        id = "vm-mori";
        mac = "02:00:00:00:00:01";
      }];
      shares = [
        {
          source = "/persist/vms/machina-mori/sliver-server";
          mountPoint = "/var/lib/sliver";
          type = "9p";
        }
        {
          source = "/persist/vms/machina-mori/sliver-client";
          mountPoint = "/home/rei/.sliver-client";
          type = "9p";
        }
      ];
      balloonMem = 4096;
      vcpu = 4;
      qemu.spice = {
        enabled = true;
        socket = "/run/microvm/machina-mori/spice.sock";
      };
    };

    boot.kernelParams = ["reboot=acpi" "console=ttyS0"];
    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.loader.timeout = lib.mkForce 0;
    boot.plymouth.enable = lib.mkForce false;
    boot.consoleLogLevel = 3;
  };
}
