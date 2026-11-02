# chimera.nvf.lsp.full — heavy languages for the full profile (overlord).
# Adds to whatever chimera.nvf.lsp.light already enabled; the profiles merge.
{...}: {
  chimera.nvf.lsp.full = {
    homeManager = {
      pkgs,
      lib,
      ...
    }: {
      programs.nvf.settings.vim = {
        extraPackages = [pkgs.cmake];
        languages = {
          nix.enable = true;
          rust.enable = true;
          go.enable = true;
          java = {
            enable = true;
            lsp.enable = false; # nvim-jdtls starts/owns the jdtls client itself (below)
          };
          # no separate javascript module — typescript covers JS tooling
          typescript.enable = true;
          html.enable = true;
          css.enable = true;
          clang.enable = true; # covers both C and C++ via clangd — was hand-registered as `clangd` in lsp-attach.lua
        };

        lsp.servers = {
          # Scope nixd to the chimera flake only; everything else falls to nil_ls.
          nixd = {
            root_dir = lib.generators.mkLuaInline ''
              function(bufnr, on_dir)
                local chimera = vim.fs.normalize '~/Projects/chimera'
                local path = vim.api.nvim_buf_get_name(bufnr)
                if vim.fs.normalize(path):sub(1, #chimera) == chimera then
                  on_dir(chimera)
                end
              end
            '';
            settings.nixd = {
              nixpkgs.expr = "import (builtins.getFlake \"/home/oxce5/Projects/chimera\").inputs.nixpkgs { }";
              options = {
                nixos.expr = "(builtins.getFlake \"/home/oxce5/Projects/chimera\").nixosConfigurations.overlord.options";
                home_manager.expr = "(builtins.getFlake \"/home/oxce5/Projects/chimera\").homeConfigurations.\"oxce5@overlord\".options";
              };
            };
          };

          # Not an nvf nix default — added as its own LSP entry, with the
          # inverse root_dir condition so it never competes with nixd inside
          # chimera.
          nil_ls = {
            cmd = [(lib.getExe pkgs.nil)];
            filetypes = ["nix"];
            root_dir = lib.generators.mkLuaInline ''
              function(bufnr, on_dir)
                local chimera = vim.fs.normalize '~/Projects/chimera'
                local path = vim.api.nvim_buf_get_name(bufnr)
                if vim.fs.normalize(path):sub(1, #chimera) ~= chimera then
                  on_dir(vim.fs.root(bufnr, { 'flake.nix', '.git' }) or vim.fs.dirname(path))
                end
              end
            '';
            settings."nil".formatting.command = ["alejandra" "--quiet" "-"];
          };

          lua_ls = {
            on_init = lib.generators.mkLuaInline ''
              function(client)
                client.server_capabilities.documentFormattingProvider = false
                if client.workspace_folders then
                  local path = client.workspace_folders[1].name
                  if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
                end
                client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
                  runtime = {
                    version = 'LuaJIT',
                    path = { 'lua/?.lua', 'lua/?/init.lua' },
                  },
                  workspace = {
                    checkThirdParty = false,
                    library = vim.tbl_extend('force', vim.api.nvim_get_runtime_file("", true), {
                      "''${3rd}/luv/library",
                      "''${3rd}/busted/library",
                    }),
                  },
                })
              end
            '';
            settings.Lua.format.enable = false;
          };
        };

        # jdtls rides along with the java language; only the full profile pays for it.
        lazy.plugins."nvim-jdtls" = {
          package = pkgs.vimPlugins.nvim-jdtls;
          ft = ["java"];
        };

        # jdtls configuration (self-managed LSP, started imperatively on FileType)
        luaConfigRC = {
          jdtls = {
            data = ''
              local JAVA_DEBUG_JAR = vim.fn.glob(vim.fn.expand '~/dev/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar')
              local JAVA_TEST_JARS = vim.split(vim.fn.glob(vim.fn.expand '~/dev/vscode-java-test/server/*.jar', true), '\n')

              local function setup_jdtls()
                local jdtls = require 'jdtls'
                local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
                local workspace_dir = vim.fn.stdpath 'data' .. '/jdtls-workspace/' .. project_name

                local bundles = { JAVA_DEBUG_JAR }
                vim.list_extend(bundles, JAVA_TEST_JARS)

                local config = {
                  cmd = { 'jdtls', '-data', workspace_dir },
                  root_dir = require('jdtls.setup').find_root { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' },
                  settings = {
                    java = {
                      eclipse = { downloadSources = true },
                      configuration = { updateBuildConfiguration = 'interactive' },
                      maven = { downloadSources = true },
                      implementationsCodeLens = { enabled = true },
                      referencesCodeLens = { enabled = true },
                      references = { includeDecompiledSources = true },
                      format = { enabled = true },
                      signatureHelp = { enabled = true },
                      completion = {
                        favoriteStaticMembers = {
                          'org.junit.Assert.*',
                          'org.junit.jupiter.api.Assertions.*',
                          'org.mockito.Mockito.*',
                        },
                      },
                      inlayHints = { parameterNames = { enabled = 'all' } },
                    },
                  },
                  init_options = {
                    bundles = bundles,
                    extendedClientCapabilities = jdtls.extendedClientCapabilities,
                  },
                  on_attach = function(_, bufnr)
                    jdtls.setup_dap { hotcodereplace = 'auto' }
                    require('jdtls.dap').setup_dap_main_class_configs()
                    local opts = { buffer = bufnr }
                    vim.keymap.set('n', '<leader>co', jdtls.organize_imports, opts)
                    vim.keymap.set('n', 'crv', jdtls.extract_variable, opts)
                    vim.keymap.set('v', 'crv', function() jdtls.extract_variable(true) end, opts)
                    vim.keymap.set('n', 'crc', jdtls.extract_constant, opts)
                    vim.keymap.set('v', 'crc', function() jdtls.extract_constant(true) end, opts)
                    vim.keymap.set('v', 'crm', function() jdtls.extract_method(true) end, opts)
                    vim.keymap.set('n', '<leader>df', jdtls.test_class, opts)
                    vim.keymap.set('n', '<leader>dn', jdtls.test_nearest_method, opts)
                    vim.keymap.set('n', '<leader>tu', jdtls.update_project_config, opts)
                  end,
                }
                jdtls.start_or_attach(config)
              end

              vim.api.nvim_create_autocmd('FileType', {
                pattern = 'java',
                group = vim.api.nvim_create_augroup('jdtls-java', { clear = true }),
                callback = setup_jdtls,
              })
            '';
            before = [];
            after = ["pluginConfigs"];
          };
        };
      };
    };
  };
}
