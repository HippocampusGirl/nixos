{ config, ... }: {
  imports = [ ../../packages/garm.nix ];
  services = {
    garm = {
      enable = true;
      config = {
        default = {
          debug_server = false;

          callback_url = "https://garm.lea.science/api/v1/callbacks/status";
          metadata_url = "https://garm.lea.science/api/v1/metadata";

          enable_webhook_management = true;
          webhook_url = "https://garm.lea.science/webhooks";
        };
        logging = {
          enable_log_streamer = true;
          log_format = "text";
          log_level = "debug";
          log_source = true;
        };
        metrics = {
          enable = true;
        };
        jwt_auth = {
          secret._secret = config.sops.secrets."garm/jwt-auth-secret".path;
          time_to_live = "8760h";
        };
        apiserver = {
          bind = "127.0.0.1";
          port = 13464;
          use_tls = false;
          cors_origins = [ "*" ];
        };
        database = {
          backend = "sqlite3";
          passphrase._secret = config.sops.secrets."garm/database-passphrase".path;
          sqlite3.db_file = "/var/lib/garm/garm.db";
        };
        github = [
          {
            name = "hippocampusgirl";
            oauth2_token._secret = config.sops.secrets."garm/github-token".path;
          }
        ];
      };
      providers = {
        "local" = {
          type = "lxd";
          config = {
            unix_socket_path = "/var/lib/lxd/unix.socket";
            include_default_profile = false;
            instance_type = "container";
            secure_boot = true;
            project_name = "default";
            image_remotes = {
              "ubuntu_daily" = {
                addr = "https://cloud-images.ubuntu.com/daily";
                public = true;
                protocol = "simplestreams";
                skip_verify = false;
              };
            };
          };
        };
        "denbi" = {
          type = "openstack";
          config = {
            cloud = "openstack";
            network_id = "18043a8f-7c67-438b-baa8-513e5cb07d47";

            boot_from_volume = true;
            root_disk_size = 72;

            credentials = { clouds = config.sops.secrets."denbi/clouds".path; };
          };
        };
      };
    };
    nginx = {
      virtualHosts = {
        "garm.lea.science" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://localhost:13464";
            proxyWebsockets = true;
          };
        };
      };
    };
  };
  sops = {
    secrets."garm/jwt-auth-secret" = { };
    secrets."garm/database-passphrase" = { };
    secrets."garm/github-token" = { };
    secrets."denbi/clouds" = { };
  };
}
