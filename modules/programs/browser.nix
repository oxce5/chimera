{chimera, ...}: {
  chimera.browser.provides = {
    base = {
      homeManager = {
        lib,
        config,
        ...
      }: {
        programs.firefox = {
          enable = true;

          languagePacks = ["en-US"];

          policies = {
            # Updates & Background Services
            AppAutoUpdate = false;
            BackgroundAppUpdate = false;

            # Feature Disabling
            DisableBuiltinPDFViewer = false;
            DisableFirefoxStudies = true;
            DisableFirefoxAccounts = true;
            DisableFirefoxScreenshots = true;
            DisableForgetButton = true;
            DisableMasterPasswordCreation = true;
            DisableProfileImport = true;
            DisableProfileRefresh = true;
            DisableSetDesktopBackground = true;
            DisablePocket = true;
            DisableTelemetry = true;
            DisableFormHistory = true;
            DisablePasswordReveal = true;

            # Access Restrictions
            BlockAboutConfig = false;
            BlockAboutProfiles = false;
            BlockAboutSupport = false;

            # UI and Behavior
            DisplayMenuBar = "never";
            DontCheckDefaultBrowser = true;
            HardwareAcceleration = true;
            OfferToSaveLogins = false;
            DefaultDownloadDirectory = "${config.home.homeDirectory}/Downloads";

            # Extensions
            ExtensionSettings = let
              mkExtension = short: {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/${short}/latest.xpi";
                installation_mode = "force_installed";
                updates_disabled = true;
              };
            in {
              "*".installation_mode = "blocked";
              "uBlock0@raymondhill.net" = mkExtension "ublock-origin";
              "{73a6fe31-595d-460b-a920-fcc0f8843232}" = mkExtension "noscript";
              "vpn@proton.ch" = mkExtension "proton-vpn-firefox-extension";
              "78272b6fa58f4a1abaac99321d503a20@proton.me" = mkExtension "proton-pass";
              "{f1ec051a-61c9-4613-a6bc-17253b7b3bf3}" = mkExtension "teto";
            };

            # Extension configuration
            "3rdparty".Extensions = {
              "uBlock0@raymondhill.net".adminSettings = {
                userSettings = rec {
                  uiTheme = "dark";
                  uiAccentCustom = true;
                  uiAccentCustom0 = "#8300ff";
                  cloudStorageEnabled = lib.mkForce false;

                  importedLists = [
                    "https:#filters.adtidy.org/extension/ublock/filters/3.txt"
                    "https:#github.com/DandelionSprout/adfilt/raw/master/LegitimateURLShortener.txt"
                  ];

                  externalLists = lib.concatStringsSep "\n" importedLists;
                };

                selectedFilterLists = [
                  "CZE-0"
                  "adguard-generic"
                  "adguard-annoyance"
                  "adguard-social"
                  "adguard-spyware-url"
                  "easylist"
                  "easyprivacy"
                  "https:#github.com/DandelionSprout/adfilt/raw/master/LegitimateURLShortener.txt"
                  "plowe-0"
                  "ublock-abuse"
                  "ublock-badware"
                  "ublock-filters"
                  "ublock-privacy"
                  "ublock-quick-fixes"
                  "ublock-unbreak"
                  "urlhaus-1"
                ];
              };
            };
          };
        };
      };
    };

    firefox = {
      includes = [chimera.browser._.base];

      homeManager = {
        programs.firefox = {
          # Dark Reader lives only in the Personal profile, so it is not
          # force-installed from base; merely whitelisted to keep the copy
          # already installed in Personal working.
          policies.ExtensionSettings = {
            "addon@darkreader.org".installation_mode = "allowed";
          };

          profiles = {
            Personal = {
              id = 0;
              isDefault = true;
              search = {
                force = true;
                default = "ddg";
                privateDefault = "ddg";
              };
            };
            School = {
              id = 1;
            };
          };
        };
      };
    };

    pentest = {
      includes = [chimera.browser._.base];

      homeManager = {
        pkgs,
        config,
        lib,
        ...
      }: {
        wayland.windowManager.niri.settings.binds = {
          "Mod+B" = {
            _props.hotkey-overlay-title = "Open Browser";
            spawn = "firefox";
          };
        };

        programs.firefox = {
          package = pkgs.firefox-esr;

          policies = {
            # Extensions
            ExtensionSettings = let
              mkExtension = short: {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/${short}/latest.xpi";
                installation_mode = "force_installed";
                updates_disabled = true;
              };
            in {
              "wappalyzer@crunchlabz.com" = mkExtension "wappalyzer";
              "foxyproxy@eric.h.jung" = mkExtension "foxyproxy-standard";
            };
          };
        };
      };
    };
  };
}
