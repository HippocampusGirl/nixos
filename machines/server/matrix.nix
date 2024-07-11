{ config, pkgs, ... }:
let
  port = 13484;
  name = "matrix-synapse";
in {
  services = {
    dendrite = {
      enable = true;
      httpPort = port;
      environmentFile = config.sops.secrets."dendrite/registration-secret".path;

      settings = {
        global = { server_name = "fmri.science"; };

        enable_metrics = true;
        url_preview_enabled = true;

        max_upload_size = "100M";

        enable_registration = false;
        registration_requires_token = true;

        database = {
          name = "psycopg2";
          database = name;
        };

        listeners = [{
          type = "http";
          bind_addresses = [ "localhost" ];
          inherit port;
          tls = false;
          x_forwarded = true;
          resources = [{
            compress = false;
            names = [ "client" "federation" ];
          }];
        }];
      };
    };

    nginx = {
      virtualHosts = {
        "matrix.fmri.science" = {
          forceSSL = true;
          enableACME = true;

          locations = {
            "/".extraConfig = ''
              return 404;
            '';
            "/_matrix" = { proxyPass = "http://localhost:${toString (port)}"; };
            "/_synapse" = {
              proxyPass = "http://localhost:${toString (port)}";
            };
          };
        };
        "chat.fmri.science" = {
          forceSSL = true;
          enableACME = true;

          root = pkgs.element-web.override {
            conf = {
              default_server_config."m.homeserver" = {
                "base_url" = "https://matrix.fmri.science";
                "server_name" = "fmri.science";
              };
              showLabsSettings = true;
            };
          };
        };
      };
    };

    postgresql = {
      ensureDatabases = [ name ];
      ensureUsers = [{
        name = name;
        ensureDBOwnership = true;
      }];
    };
  };

  sops = { secrets."dendrite/registration-secret" = { }; };
}
