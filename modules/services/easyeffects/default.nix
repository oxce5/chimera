{
  chimera.easyeffects.homeManager = {
    # systemd.user.services.easyeffects.Service.Restart = lib.mkForce "never";
    wayland.windowManager.niri.settings.spawn-at-startup = ["easyeffects"];
    services.easyeffects = {
      enable = true;
      extraPresets = let
        presets = [
          "Default"
          "KZ Castor Pro"
        ];
        mkPresets = names:
          builtins.listToAttrs (
            map (name: {
              inherit name;
              value = builtins.fromJSON (builtins.readFile (./presets + "/${name}.json"));
            })
            names
          );
      in
        mkPresets presets;
    };
  };
}
