{__findFile, ...}: {
  chimera = {
    workstation = {
      includes = [
        <chimera/boot>
        <chimera/dev>
        <chimera/networking>
        <chimera/theming>
        # Chromium-family policy is machine-wide (/etc/chromium/policies), so
        # base-helium's nixos half must be reached via a host role; its
        # homeManager part is inert here and reaches users through
        # <chimera/apps/gui> (and <chimera/browser/pentest-helium>).
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
        # Hardened helium: block-all + force-installed pentest extensions.
        # Like <chimera/pwn>, this aspect is included again by the
        # pentest-user role for its homeManager half.
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
