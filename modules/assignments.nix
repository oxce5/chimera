{
  den,
  __findFile,
  ...
}: {
  # Host roles: the machine's system-level shape.
  chimera = {
    workstation = {
      includes = [
        <chimera/boot>
        <chimera/dev>
        <chimera/networking>
        <chimera/theming>
        # nixos half; HM half arrives via the workstation-user role
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
        # nixos halves; HM halves arrive via the pentest-user role
        <chimera/pwn>
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

    # User roles: the person's shared environment.
    desktop-base = {
      includes = [
        <chimera/shell>
        (den.batteries.user-shell "fish")
        <chimera/batteries/privileged-user>

        <chimera/wayland/niri>
        <chimera/wayland/vicinae>

        <chimera/fish>
        <chimera/apps/yazi>
      ];
    };

    workstation-user = {
      includes = [
        <chimera/desktop-base>

        <chimera/shell/enhanced>

        <chimera/wayland/mirror>
        <chimera/wayland/screenshot>
        <chimera/wayland/cast>
        <chimera/desktop-shells/noctalia>

        # <chimera/easyeffects>
        <chimera/tailscale>
        # <chimera/flatpak>
        <chimera/xdg>

        # <chimera/gaming/max>

        <chimera/dev/min>
        <chimera/dev/ai>
        # <chimera/apps/coreutils/desktop>
        <chimera/apps/gui>
        <chimera/apps/git>

        <chimera/services/syncthing>
        <chimera/services/printing>
      ];
    };

    # The throwaway VM: a lean desktop plus the offensive tooling.
    pentest-user = {
      includes = [
        <chimera/desktop-base>

        <chimera/apps/coreutils-slim>
        # <chimera/browser/pentest>
        # HM half of pentest-helium; its nixos half comes via the vm host role
        <chimera/browser/pentest-helium>
        <chimera/dev/base>
        <chimera/dev/lsp>
        <chimera/dev/sessions>
        <chimera/pwn>
        # only for its homeManager half; host-role HM content is inert
        <chimera/virt/headless>
      ];
    };
  };

  # The only place entities are connected to roles.
  den.aspects = {
    overlord.includes = [
      <chimera/laptop>
      <chimera/apps/openrgb>
      <chimera/virt/host>
      <chimera/virt/docker>

      <chimera/impermanence/tmp>
      <chimera/impermanence/root>
    ];

    machina-mori.includes = [
      <chimera/vm>
      <chimera/virt/guest>
    ];

    oxce5.includes = [
      den.batteries.primary-user
      <chimera/workstation-user>
      <chimera/storage>
    ];

    rei.includes = [
      den.batteries.primary-user
      # <chimera/desktop-shells/noctalia>
      <chimera/pentest-user>
    ];
  };
}
