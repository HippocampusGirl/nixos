{ config, lib, ... }:
let
  name = "upload";
  port = 13481;
in {
  services = {
    upload-server = {
      inherit port;
      enable = true;
      publicKeyFile = config.sops.secrets."upload-server/public-key".path;
      database = {
        type = "postgres";
        connection-string = "socket://${name}@/var/run/postgresql?db=${name}";
      };
    };
    nginx = {
      virtualHosts = {
        "upload.gwas.science" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://localhost:${toString (port)}";
            proxyWebsockets = true;
          };
        };
      };
    };
    postgresql = {
      enable = lib.mkForce true;
      ensureDatabases = [ name ];
      ensureUsers = [{
        name = name;
        ensureDBOwnership = true;
      }];
    };
  };
  sops = {
    secrets."upload-server/public-key" = { owner = "${name}"; };
  };
  systemd.services.upload-server.serviceConfig.User = "${name}";
  users.groups.${name} = { };
  users.users.${name} = {
    isSystemUser = true;
    group = "${name}";
  };
}
