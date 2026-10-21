{
  inputs,
  chimera,
  ...
}: let
  webstore = "https://clients2.google.com/service/update2/crx";

  # hash-pinned store snapshot; version and hash move together
  fetchStoreCrx = pkgs: id: version: hash:
    pkgs.fetchurl {
      name = "${id}.crx";
      url = "${webstore}?response=redirect&os=linux&arch=x64&os_arch=x86_64&nacl_arch=x86-64&prod=chromiumcrx&prodchannel=unknown&prodversion=155.0.8059.84&acceptformat=crx2,crx3&x=id%3D${id}%26uc";
      sha256 = hash;
    };

  # runCommand, not toJSON: keeps the crx in the closure
  mkCrxJson = pkgs: crx: id: version:
    pkgs.runCommand "${id}.json" {} ''
      cat > $out <<EOF
      {"external_crx": "${crx}", "external_version": "${version}"}
      EOF
    '';

  # extensions with a crx also need an external registration
  vendored = e: e.crx != null;

  # fetched or in-tree bytes; exactly one, see the assertion
  crxSource = pkgs: e:
    if e.crx.hash != null
    then fetchStoreCrx pkgs e.id e.crx.version e.crx.hash
    else "${e.crx.path}";

  # helium's user data dir
  configDir = "net.imput.helium";
in {
  chimera.browser.provides = {
    base-helium = {
      nixos = {
        lib,
        config,
        ...
      }: let
        # fold entries into the single ExtensionSettings dict
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
            {
              id = "doojmbjmlfjjnbmnoijecmcbfeoakpjm";
              installation_mode = "allowed";
              update_url = null;
              toolbar_pin = "force_pinned";
              crx.version = "13.6.34";
              crx.hash = "00mf98v9v6ag9plx0ncv4mm3lbmwd9sniqv98xig90z7fjsk1daz";
            }
            {
              id = "jplgfhpmjnbigmhklmmbgecoobifkmpa";
              installation_mode = "allowed";
              update_url = null;
              toolbar_pin = "force_pinned";
              crx.version = "1.3.6";
              crx.hash = "1ba14qwxprc1skw2gddgqz64amw6ylq43njc2lsf152a81g0yg5x";
            }
            {
              id = "ghmbeldphafepmbegfdlkpapadhbakde";
              installation_mode = "allowed";
              update_url = null;
              toolbar_pin = "force_pinned";
              crx.version = "1.42.0";
              crx.hash = "04izkmx8hggsgdb5vy6m3fxrs1ai5a5afgrs017ihpd0ijs8ppvf";
            }
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

          programs.chromium = {
            enable = true;
            extraOpts = {
              BrowserSignin = 0;
              SyncDisabled = true;

              MetricsReportingEnabled = false;
              UrlKeyedAnonymizedDataCollectionEnabled = false;
              SafeBrowsingExtendedReportingEnabled = false;
              FeedbackSurveysEnabled = false;

              AlwaysOpenPdfExternally = false;
              DisableScreenshots = true;
              AutofillAddressEnabled = false;
              AutofillCreditCardEnabled = false;

              ImportAutofillFormData = false;
              ImportBookmarks = false;
              ImportHistory = false;
              ImportHomepage = false;
              ImportSavedPasswords = false;
              ImportSearchEngine = false;

              DefaultBrowserSettingEnabled = false;
              HardwareAccelerationModeEnabled = true;
              PasswordManagerEnabled = false;
              BackgroundModeEnabled = false;

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
        wayland.windowManager.niri.settings.binds = {
          "Mod+B" = {
            _props.hotkey-overlay-title = "Open Browser";
            spawn = "helium";
          };
        };

        programs.chromium = {
          enable = true;
          package = inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default;
        };

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

    # hardened variant: appends the pentest pair to the shared list
    pentest-helium = {
      includes = [chimera.browser._.base-helium];

      nixos = {
        config.programs.helium.extensions = [
          {
            id = "gppongmhjkpfnbhagpmjfkannfbllamg";
            installation_mode = "allowed";
            update_url = null;
            toolbar_pin = "force_pinned";
            crx.version = "6.12.7";
            crx.hash = "1h6v4hr4n6adsdqg1nicmwrhycpzsxz1w1ml1nckryyc248cia74";
          }
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
