{
  inputs,
  chimera,
  ...
}: let
  webstore = "https://clients2.google.com/service/update2/crx";

  # snapshot of a store CRX. Client params are pinned so the served bytes
  # are stable. bumping a version means updating `version` and `hash`
  # together (nix hash file --type sha256 --base32 <crx>).
  fetchStoreCrx = pkgs: id: version: hash:
    pkgs.fetchurl {
      name = "${id}.crx";
      url = "${webstore}?response=redirect&os=linux&arch=x64&os_arch=x86_64&nacl_arch=x86-64&prod=chromiumcrx&prodchannel=unknown&prodversion=155.0.8059.84&acceptformat=crx2,crx3&x=id%3D${id}%26uc";
      sha256 = hash;
    };

  # Built in a runCommand, not writeText+toJSON: toJSON drops string
  # context, so the CRX store path in external_crx would silently fall out
  # of the system closure. Through the runCommand the CRX is a real build
  # input.
  mkCrxJson = pkgs: crx: id: version:
    pkgs.runCommand "${id}.json" {} ''
      cat > $out <<EOF
      {"external_crx": "${crx}", "external_version": "${version}"}
      EOF
    '';

  # An extension with a `crx` block is vendored: it installs from a store
  # copy of the crx rather than from the web store, so it needs an
  # external_crx registration on top of its policy entry.
  vendored = e: e.crx != null;

  # The bytes behind a vendored extension: fetched and hash-pinned at build
  # time, or already in the tree. Exactly one of the two, enforced below.
  crxSource = pkgs: e:
    if e.crx.hash != null
    then fetchStoreCrx pkgs e.id e.crx.version e.crx.hash
    else "${e.crx.path}";

  # User data dir, reverse-dns style like every other chromium build.
  configDir = "net.imput.helium";
in {
  chimera.browser.provides = {
    base-helium = {
      nixos = {
        lib,
        config,
        ...
      }: let
        # ExtensionSettings is a single dictionary policy, and variants only
        # extend the extensions list below - this folds it into the one
        # managed file nixpkgs renders.
        mkExtensionSettings = entries:
          lib.foldl (acc: e:
            acc
            // {
              ${e.id} =
                {
                  installation_mode = e.installation_mode;
                }
                // lib.optionalAttrs (e.update_url != null) {update_url = e.update_url;}
                // lib.optionalAttrs (e.toolbar_pin != null) {toolbar_pin = e.toolbar_pin;};
            }) {"*".installation_mode = "blocked";}
          entries;
      in {
        options.programs.helium.extensions = lib.mkOption {
          type = lib.types.listOf (lib.types.submodule {
            options = {
              id = lib.mkOption {type = lib.types.strMatching "[a-z]{32}";};
              installation_mode = lib.mkOption {
                type = lib.types.enum ["blocked" "allowed" "normal_installed" "force_installed" "removed"];
                default = "force_installed";
              };
              update_url = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = webstore;
              };
              toolbar_pin = lib.mkOption {
                type = lib.types.nullOr (lib.types.enum ["force_pinned" "force_unpinned"]);
                default = null;
              };
              # Vendored bytes: a store copy of the crx, so the extension
              # installs from an external_crx registration instead of the
              # web store. `hash` fetches one at build time, `path` points at
              # one already in the tree; version moves with whichever.
              crx = lib.mkOption {
                type = lib.types.nullOr (lib.types.submodule {
                  options = {
                    version = lib.mkOption {type = lib.types.str;};
                    hash = lib.mkOption {
                      type = lib.types.nullOr lib.types.str;
                      default = null;
                    };
                    path = lib.mkOption {
                      type = lib.types.nullOr lib.types.path;
                      default = null;
                    };
                  };
                });
                default = null;
              };
            };
          });
          default = [];
        };

        config = {
          programs.helium.extensions = [
            # NoScript - Maximum protection
            {
              id = "doojmbjmlfjjnbmnoijecmcbfeoakpjm";
              installation_mode = "allowed";
              update_url = null;
              toolbar_pin = "force_pinned";
              crx.version = "13.6.34";
              crx.hash = "00mf98v9v6ag9plx0ncv4mm3lbmwd9sniqv98xig90z7fjsk1daz";
            }
            # Proton VPN: Fast & Secure
            {
              id = "jplgfhpmjnbigmhklmmbgecoobifkmpa";
              installation_mode = "allowed";
              update_url = null;
              toolbar_pin = "force_pinned";
              crx.version = "1.3.6";
              crx.hash = "1ba14qwxprc1skw2gddgqz64amw6ylq43njc2lsf152a81g0yg5x";
            }
            # Proton Pass: Free Password Manager
            {
              id = "ghmbeldphafepmbegfdlkpapadhbakde";
              installation_mode = "allowed";
              update_url = null;
              toolbar_pin = "force_pinned";
              crx.version = "1.42.0";
              crx.hash = "04izkmx8hggsgdb5vy6m3fxrs1ai5a5afgrs017ihpd0ijs8ppvf";
            }
            # Teto theme, pre-packed by hand (--pack-extension). The pack key
            # is deliberately not committed - it lives in
            # ~/.local/share/helium-pack/pack.pem. The id is sha256 of that
            # key's SPKI DER, hex digits mapped 0-f -> a-p, so repacking with
            # the same key keeps the same id everywhere here. allowed, never
            # force_installed: a policy force makes the updater own the id
            # and deny the external install (observed: the externals install
            # fine while the one forced external never landed). Fresh
            # profiles pick the theme up on install instead. The same holds
            # for every other vendored extension here.
            {
              id = "bmelpfagljkbijcfdmgpngdgkogafnjl";
              installation_mode = "allowed";
              update_url = null;
              crx.version = "2.3";
              crx.path = ./_teto-helium-theme/teto-helium-theme.crx;
            }
          ];

          assertions = [
            {
              assertion =
                lib.all (e: (e.crx == null) || ((e.crx.hash != null) != (e.crx.path != null)))
                config.programs.helium.extensions;
              message = "programs.helium.extensions: a vendored crx needs exactly one of hash or path";
            }
          ];

          # Chromium on Linux reads /etc/chromium/policies, machine-wide only:
          # chrome://policy came back empty while the equivalent file sat in
          # the user config dir. programs.chromium renders it for us, so the
          # policies live in an `nixos` half and, like <chimera/pwn>, the
          # aspect is reached twice: via a host role for the nixos half, via a
          # user role for its homeManager half.
          programs.chromium = {
            enable = true;

            # One freeform blob: nixpkgs types none of it, which is what buys
            # ExtensionSettings with its per-id installation_mode.
            extraOpts = {
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

              # Extensions: nixpkgs only offers ExtensionInstallForcelist,
              # which force-installs from the web store - and a policy force
              # makes the updater own the id and deny the external install
              # (observed: the externals install fine while the one forced
              # external never landed). Hence the folded dict: block by
              # default, `allowed` per vendored extension, so the browser
              # takes them from the store.
              ExtensionSettings = mkExtensionSettings config.programs.helium.extensions;
            };
          };
        };
      };

      homeManager = {
        pkgs,
        lib,
        osConfig,
        ...
      }: {
        # oxcl's flake is used for the package only; its modules are not
        # imported. Upstream's home-manager module takes the package and puts
        # it in home.packages, but its extension files are hardcoded to
        # ~/.config/chromium, which is not where Helium keeps its user data -
        # hence the registrations below.
        programs.chromium = {
          enable = true;
          package = inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default;
        };

        # External-extension registration, the way home-manager's chromium
        # module does it: one <id>.json per extension in the user data dir,
        # which the browser installs at startup (and re-installs when
        # external_version changes). Per-user, so no root and no tmpfiles.
        # Policy is machine-wide and stays in the nixos half; the two halves
        # meet through osConfig.programs.helium.extensions.
        xdg.configFile = lib.listToAttrs (
          map (e: {
            name = "${configDir}/External Extensions/${e.id}.json";
            value.source = mkCrxJson pkgs (crxSource pkgs e) e.id e.crx.version;
          }) (lib.filter vendored osConfig.programs.helium.extensions)
        );
      };
    };

    helium = {
      includes = [chimera.browser._.base-helium];
    };

    # Hardened variant for the pentest VM: base already blocks everything
    # and installs the daily set, so this only appends the pentest pair.
    # Machine-wide policy is the point - every helium profile on that host
    # gets daily + pentest extensions, and chrome://policy sees a single
    # unconflicted ExtensionSettings dict.
    pentest-helium = {
      includes = [chimera.browser._.base-helium];

      # Only the policy entries: base-helium already folds whatever lands in
      # programs.helium.extensions into the one managed file and registers a
      # CRX for every vendored one, so adding an extension here needs nothing
      # else.
      nixos = {config, ...}: {
        config.programs.helium.extensions = [
          # Wappalyzer - Technology profiler
          {
            id = "gppongmhjkpfnbhagpmjfkannfbllamg";
            installation_mode = "allowed";
            update_url = null;
            toolbar_pin = "force_pinned";
            crx.version = "6.12.7";
            crx.hash = "1h6v4hr4n6adsdqg1nicmwrhycpzsxz1w1ml1nckryyc248cia74";
          }
          # FoxyProxy Standard
          {
            id = "gcknhkkoolaabfmlnjonogaaifnjlfnp";
            installation_mode = "allowed";
            update_url = null;
            toolbar_pin = "force_pinned";
            crx.version = "9.7";
            crx.hash = "087ski62pnipg3cyfcviwk6pfv773m38d5vcxlan2wh72dndssac";
          }
        ];
      };
    };
  };
}
