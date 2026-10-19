{
  inputs,
  chimera,
  ...
}: {
  # Chromium-family policy enforcement on Linux is machine-wide only: this
  # build of Helium reads /etc/chromium/policies/{managed,recommended} and
  # nothing else - chrome://policy showed an empty set while the oxcl
  # home-manager module happily wrote ~/.config/helium/policies/managed/…
  # (Chromium has no per-profile policy files, unlike Firefox). So the
  # policies live in an `nixos` half and, like <chimera/pwn>, the aspect is
  # reached twice: via a host role for the nixos half, via a user role for
  # its homeManager half.
  chimera.browser.provides = {
    base-helium = {
      nixos = {
        pkgs,
        config,
        ...
      }: let
        helium = inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default;

        # Pre-packed CRX (built once by hand with --pack-extension). The pack
        # key is deliberately not committed - it lives in
        # ~/.local/share/helium-pack/pack.pem. The extension ID is sha256 of
        # that key's SPKI DER, hex digits mapped 0-f -> a-p, so regenerating
        # the CRX with the same key keeps the same ID everywhere below.
        tetoCrx = "${./_teto-helium-theme/teto-helium-theme.crx}";
        tetoExtId = "bmelpfagljkbijcfdmgpngdgkogafnjl";
        tetoVersion = "2.3";

        # Built in a runCommand, not writeText+toJSON: toJSON drops string
        # context, so the CRX store path in external_crx would silently fall
        # out of the system closure. Through the runCommand the CRX is a
        # real build input.
        tetoExternalJson = pkgs.runCommand "${tetoExtId}.json" {} ''
          cat > $out <<EOF
          {"external_crx": "${tetoCrx}", "external_version": "${tetoVersion}"}
          EOF
        '';
      in {
        environment.etc."chromium/policies/managed/helium.json".text = builtins.toJSON {
          # Sign-in / sync
          BrowserSignin = 0;
          SyncDisabled = true;

          # Telemetry (DisableTelemetry, studies/surveys)
          MetricsReportingEnabled = false;
          UrlKeyedAnonymizedDataCollectionEnabled = false;
          SafeBrowsingExtendedReportingEnabled = false;
          FeedbackSurveysEnabled = false;

          # Feature disabling
          AlwaysOpenPdfExternally = false;
          DisableScreenshots = true;
          PasswordRevealEnabled = false;
          AutofillAddressEnabled = false;
          AutofillCreditCardEnabled = false;

          # DisableProfileImport
          ImportAutofillFormData = false;
          ImportBookmarks = false;
          ImportHistory = false;
          ImportHomepage = false;
          ImportSavedPasswords = false;
          ImportSearchEngine = false;

          # UI and behavior
          DefaultBrowserSettingEnabled = false;
          HardwareAccelerationModeEnabled = true;
          PasswordManagerEnabled = false;
          BackgroundModeEnabled = false;

          # Extensions: same shape as the firefox base set. Store installs
          # of stock uBlock Origin are dead on chromium >= 139 (MV2) and
          # Helium bundles its own fork, so none here.
          ExtensionSettings = {
            "*".installation_mode = "blocked";

            # NoScript - Maximum protection
            "doojmbjmlfjjnbmnoijecmcbfeoakpjm" = {
              installation_mode = "force_installed";
              update_url = "https://clients2.google.com/service/update2/crx";
            };

            # Proton VPN: Fast & Secure
            "jplgfhpmjnbigmhklmmbgecoobifkmpa" = {
              installation_mode = "force_installed";
              update_url = "https://clients2.google.com/service/update2/crx";
            };

            # Proton Pass: Free Password Manager
            "ghmbeldphafepmbegfdlkpapadhbakde" = {
              installation_mode = "force_installed";
              update_url = "https://clients2.google.com/service/update2/crx";
            };
          };
        };

        environment.etc."chromium/policies/managed/helium-theme.json".text = builtins.toJSON {
          # A separate, disjoint file: `allowed` instead of force_installed,
          # because force_installed needs a fetchable install_url while this
          # CRX only exists in the store (registered via external_crx below).
          ExtensionSettings.${tetoExtId}.installation_mode = "allowed";
        };

        # External-extension registration: the browser installs (and
        # auto-updates-if-ver-changes) whatever sits in there at startup.
        # Per-file symlink so additional extensions compose.
        systemd.tmpfiles.rules = [
          "L+ /usr/share/chromium/extensions/${tetoExtId}.json - - - - ${tetoExternalJson}"
        ];
      };

      homeManager = {pkgs, ...}: {
        home.packages = [
          # oxcl's flake is used for the package only; its home-manager
          # module is not imported (its policy path is never read).
          (inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default)
        ];
      };
    };

    helium = {
      includes = [chimera.browser._.base-helium];
    };

    # Hardened variant for the pentest VM: the base file already blocks
    # everything and force-installs the daily set, so this file only adds
    # the pentest pair. Machine-wide scope is the point - every helium
    # profile on that host gets daily + pentest extensions.
    pentest-helium = {
      includes = [chimera.browser._.base-helium];

      nixos = {config, ...}: {
        environment.etc."chromium/policies/managed/helium-pentest.json".text = builtins.toJSON {
          ExtensionSettings = {
            # Wappalyzer - Technology profiler
            "gppongmhjkpfnbhagpmjfkannfbllamg" = {
              installation_mode = "force_installed";
              update_url = "https://clients2.google.com/service/update2/crx";
            };

            # FoxyProxy Standard
            "gcknhkkoolaabfmlnjonogaaifnjlfnp" = {
              installation_mode = "force_installed";
              update_url = "https://clients2.google.com/service/update2/crx";
            };
          };
        };
      };
    };
  };
}
