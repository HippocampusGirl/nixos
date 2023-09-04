{ lib, config, pkgs, ... }:
let
  nginxDockerRegistryExtraConfig = ''
    add_header Docker-Distribution-Api-Version registry/2.0;
    proxy_buffering off;
    proxy_request_buffering off;
    proxy_read_timeout 900;
    proxy_connect_timeout 600;
    proxy_send_timeout 600;
  '';
in {
  nginx = {
    enable = true;
    enableReload = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    # Allow large uploads
    clientMaxBodySize = "0";
    virtualHosts = {
      "server.lea.science" = {
        forceSSL = true;
        enableACME = true;
        locations."/".root = "/www";
      };
      "cr.lea.science" = {
        forceSSL = true;
        enableACME = true;
        locations = {
          "/v2" = {
            proxyPass = "http://localhost:13450";
            extraConfig = nginxDockerRegistryExtraConfig;
          };
          "/auth" = { proxyPass = "http://localhost:13451/auth"; };
        };
      };
      "garm.lea.science" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:13464";
          proxyWebsockets = true;
        };
      };
      "gwas.science" = {
        forceSSL = true;
        enableACME = true;
        locations = {
          "/v2" = {
            proxyPass = "http://localhost:13450";
            extraConfig = nginxDockerRegistryExtraConfig;
          };
        };
      };
      "fmri.science" = {
        forceSSL = true;
        enableACME = true;
        locations = {
          "/v2" = {
            proxyPass = "http://localhost:13450";
            extraConfig = nginxDockerRegistryExtraConfig;
          };
        };
      };
    };
  };
}
