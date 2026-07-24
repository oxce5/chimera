{__findFile, ...}: {
  chimera = {
    workstation = {
      includes = [
        <chimera/boot>
        <chimera/dev>
        <chimera/networking>
        <chimera/theming>
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
    vm = {
      includes = [
        <chimera/pwn>
        <chimera/workstation>
      ];
    };
  };
}
