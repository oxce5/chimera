{ den, __findFile, ...}: {
  chimera = {
    workstation = {
      includes = [
        <chimera/boot>
        <chimera/dev>
        <chimera/networking>
        <chimera/theming>
        <chimera/wayland/niri>
        <chimera/easyeffects>
        <chimera/tailscale>
        <chimera/flatpak>
        <chimera/xdg>
      ];
    };
    laptop = {
      includes = [
        <chimera/boot/graphical>
        # <chimera/boot/secure>
        <chimera/performance/responsive>
        <chimera/power-mgmt>
        <chimera/workstation>
      ];
    };
  };
}
