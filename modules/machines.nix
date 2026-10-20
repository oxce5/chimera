{__findFile, ...}: {
  chimera = {
    workstation = {
      includes = [
        <chimera/boot>
        <chimera/dev>
        <chimera/networking>
        <chimera/theming>
        # base-helium's nixos half must be reached via a host role
        <chimera/browser/base-helium>
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
        # hardened helium; also included by the pentest-user role for its HM half
        <chimera/browser/pentest-helium>
        <chimera/workstation>
        <chimera/virt/headless>
        <chimera/virt/ephemeral-store>
        <chimera/virt/audio-minimal>
        <chimera/virt/emoji-fonts>

        # Host-agnostic; overlord picks these up when it goes volatile too.
        <chimera/impermanence/tmp>
        <chimera/impermanence/root>
      ];
    };
  };
}
