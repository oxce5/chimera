{chimera, ...}: {
  chimera.wayland.provides.niri.homeManager = {
    wayland.windowManager.niri.settings = {
      # niri names output blocks `output "<connector>" { ... }`. The connector
      # name has to go through _args, otherwise the attr name itself becomes
      # the node name and niri's config parser rejects the result.
      #
      # The refresh rate is intentionally omitted: niri then picks the highest
      # rate the monitor advertises for that resolution. Pin it explicitly
      # (e.g. "1920x1080@144.000") to force a specific rate.
      output = {
        _args = ["HDMI-A-5"];
        mode = "1920x1080";
      };
    };
  };
}
