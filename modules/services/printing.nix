{chimera, ...}: {
  chimera.services._.printing = {
    nixos = {pkgs, ...}: {
      services.printing = {
        enable = true;
        drivers = with pkgs; [
          gutenprint
          gutenprintBin
          epson-escpr2
          epson-201401w
          epson-202101w
        ];
      };

      hardware.sane = {
        enable = true;
      };

      users.privilegedGroups = ["lp" "scanner"];
    };
  };
}
