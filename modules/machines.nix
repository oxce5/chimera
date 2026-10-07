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
        <chimera/virt/headless>
        <chimera/virt/ephemeral-store>
        <chimera/virt/audio-minimal>
        <chimera/virt/emoji-fonts>

        # Host-agnostic; overlord picks these up when it goes volatile too.
        <chimera/impermanence/ephemeral-tmp>
        # Inert skeleton, see chimera.impermanence.volatile-root.
        <chimera/impermanence/volatile-root>
      ];
    };
  };
}
