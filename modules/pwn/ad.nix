{chimera, ...}: {
  chimera.pwn.provides.ad = {
    homeManager = {pkgs, ...}: {
      home.packages = with pkgs; [
        # windows :(
        # ^ thank you pythonMetadataCheckPhase
        # python314Packages.bloodyad
        bloodhound-ce
        rusthound-ce
      ];
    };

    nixos = {
      pkgs,
      lib,
      ...
    }: let
      # Lab credentials. Well-known defaults, everything binds loopback.
      # Rotate for anything beyond throwaway labs.
      pgUser = "bloodhound";
      pgPassword = "bloodhoundcommunityedition";
      neo4jPassword = "bloodhoundcommunityedition";
      bhAdminPassword = "bloodhoundcommunityedition";

      apocJar = pkgs.fetchurl {
        url = "https://github.com/neo4j/apoc/releases/download/2026.07.0/apoc-2026.07.0-core.jar";
        hash = "sha256-uyVCiFjIvsLc93LlAmkIFDkwPOUj4ZvTbGkBkrZQy2M=";
      };
      gdsJar = pkgs.fetchurl {
        url = "https://github.com/neo4j/graph-data-science/releases/download/2026.07.0/neo4j-graph-data-science-2026.07.0.jar";
        hash = "sha256-+yHF3f9UXe2nrj80R4NO6/qeaPIXkK6k/f9AhxCkiWA=";
      };

      bhConfig = pkgs.writeText "bloodhound.config.json" (builtins.toJSON {
        bind_addr = "127.0.0.1:8080";
        root_url = "http://127.0.0.1:8080/";
        work_dir = "/var/lib/bloodhound/work";
        log_level = "INFO";
        graph_driver = "neo4j";
        metrics_port = "127.0.0.1:2112";
        graph_query_memory_limit = 1;
        max_graphdb_cache_size = 50;
        max_api_cache_size = 100;
        database = {
          addr = "127.0.0.1:5432";
          database = "bloodhound";
          username = pgUser;
          secret = pgPassword;
          max_concurrent_sessions = 5;
        };
        neo4j = {
          addr = "127.0.0.1:7687";
          database = "neo4j";
          username = "neo4j";
          secret = neo4jPassword;
          max_concurrent_sessions = 5;
        };
        crypto = {
          jwt.signing_key = "56bfQh/8WdS7ZJ7J2qOpVuylxZrmjl+VtkwCcseZZGQ=";
          argon2 = {
            memory_kibibytes = 1048576;
            num_iterations = 1;
            num_threads = 2;
          };
        };
        default_admin = {
          principal_name = "admin";
          password = bhAdminPassword;
          email_address = "spam@example.com";
          first_name = "Admin";
          last_name = "User";
          expire_now = false;
        };
      });
    in {
      services.postgresql = {
        enable = true;
        ensureDatabases = ["bloodhound"];
        ensureUsers = [
          {
            name = pgUser;
            ensureDBOwnership = true;
          }
        ];
        initialScript = pkgs.writeText "bloodhound-pg-init.sql" ''
          ALTER USER ${pgUser} WITH PASSWORD '${pgPassword}';
        '';
        settings = {
          shared_buffers = "128MB";
          work_mem = "4MB";
          max_connections = 20;
        };
      };

      services.neo4j = {
        enable = true;
        https.enable = false;
        workerCount = 2;
        extraServerConfig = ''
          server.memory.heap.initial_size=512m
          server.memory.heap.max_size=1g
          server.memory.pagecache.size=512m
        '';
      };

      # The stock neo4j module manages the daemon but not plugins or the
      # initial password: stage both before first start. Jars are copied
      # (not symlinked) so the module's chown never touches the store.
      systemd.services.neo4j-bloodhound-setup = {
        description = "Stage BloodHound Neo4j plugins and initial password";
        before = ["neo4j.service"];
        wantedBy = ["neo4j.service"];
        path = with pkgs; [coreutils neo4j];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          install -d -o neo4j -g neo4j -m 0700 /var/lib/neo4j/plugins
          install -o neo4j -g neo4j -m 0600 ${apocJar} /var/lib/neo4j/plugins/apoc.jar
          install -o neo4j -g neo4j -m 0600 ${gdsJar} /var/lib/neo4j/plugins/gds.jar
          if [ ! -f /var/lib/neo4j/data/dbms/auth.ini ]; then
            neo4j-admin dbms set-initial-password '${neo4jPassword}'
            chown neo4j:neo4j /var/lib/neo4j/data/dbms/auth.ini
          fi
        '';
      };

      users.users.bloodhound = {
        isSystemUser = true;
        group = "bloodhound";
        description = "BloodHound CE service user";
        home = "/var/lib/bloodhound";
      };
      users.groups.bloodhound = {};

      systemd.tmpfiles.rules = [
        "d /var/lib/bloodhound 0750 bloodhound bloodhound -"
        "d /var/lib/bloodhound/work 0750 bloodhound bloodhound -"
      ];

      systemd.services.bloodhound-ce = {
        description = "BloodHound Community Edition API";
        after = ["network.target" "postgresql.service" "neo4j.service"];
        requires = ["postgresql.service" "neo4j.service"];
        serviceConfig = {
          ExecStart = "${pkgs.bloodhound-ce}/bin/bloodhound-ce -configfile ${bhConfig}";
          User = "bloodhound";
          Restart = "on-failure";
        };
      };

      # On demand only: nothing in the stack starts at boot.
      systemd.services.postgresql.wantedBy = lib.mkForce [];
      systemd.services.neo4j.wantedBy = lib.mkForce [];
    };
  };
}
