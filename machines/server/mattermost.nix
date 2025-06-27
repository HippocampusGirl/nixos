{ lib, pkgs, ... }:
let
  name = "mattermost";
  port = 13465;
in
{
  services = {
    mattermost = {
      enable = true;
      mutableConfig = true;

      inherit port;
      siteUrl = "https://mattermost.fmri.science";

      database = {
        host = "localhost";
        inherit name;
        user = name;
        create = false;
        driver = "postgres";
        peerAuth = true;
      };

      package = pkgs.mattermostLatest;
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
