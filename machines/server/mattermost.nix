{ lib, ... }:
let
  name = "mattermost";
  port = 13465;
in {
  services = {
    mattermost = {
      enable = true;
      mutableConfig = true;

      listenAddress = "localhost:${toString (port)}";
      siteUrl = "https://mattermost.fmri.science";

      localDatabaseUser = name;
      localDatabaseName = name;
      localDatabaseCreate = false;

      extraConfig = {
        # Use unix sockets for postgresql
        SqlSettings.DataSource =
          "postgresql:///${name}?user=${name}&host=/var/run/postgresql";
      };
    };
    nginx = {
      virtualHosts = {
        "mattermost.fmri.science" = {
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
}
