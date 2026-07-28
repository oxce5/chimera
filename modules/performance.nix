{chimera, ...}: {
  chimera.performance = {
    nixos.boot = {
      kernel.sysctl = {
        "transparent_hugepage" = "always";
        "vm.nr_hugepages_defrag" = 0;
        "ipcs_shm" = 1;
        "default_hugepagez" = "1G";
        "hugepagesz" = "1G";
        "vm.compact_memory" = 0;
      };
    };
    provides = {
      responsive = {
        includes = [chimera.performance];
        nixos = {
          boot = {
            kernel.sysctl."vm.swappiness" = 5;
            kernelParams = [
              "nowatchdog"
              "nosoftlockup"
              "audit=0"
              "skew_tick=1"
              "threadirqs"
              "preempt=full"
              "nohz_full=all"
            ];
          };
          services.swapspace = {
            enable = true;
            settings = {
              max_swapsize = "1g";
              min_swapsize = "128m";
            };
          };
        };
      };
      max = {
        includes = [chimera.performance._.responsive];
        nixos.boot.kernelParams = [
          "usbcore.autosuspend=60"
          "workqueue.power_efficient=false"
          "cpufreq.default_governor=performance"
        ];
      };
    };
  };
}
