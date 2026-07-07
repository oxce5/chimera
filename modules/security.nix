{
  den.default.nixos.security = {
    sudo.enable = false;
    sudo-rs = {
      enable = true;
      execWheelOnly = true;
    };
    polkit.enable = true;
  };
}
