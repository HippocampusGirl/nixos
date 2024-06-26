{ config, lib, ... }:
let
  authListenAddress = "localhost:13451";
  registryPort = 13450;
  nginxDockerRegistryExtraConfig = ''
    add_header Docker-Distribution-Api-Version registry/2.0;
    proxy_buffering off;
    proxy_request_buffering off;
    proxy_read_timeout 900;
    proxy_connect_timeout 600;
    proxy_send_timeout 600;
  '';
  nginxDockerRegistryVirtualHost = {
    forceSSL = true;
    enableACME = true;
    locations = {
      "/v2" = {
        proxyPass = "http://localhost:${toString (registryPort)}";
        extraConfig = nginxDockerRegistryExtraConfig;
      };
    };
  };
in {
  imports = [ ../../packages/docker-auth.nix ];
  services = {
    dockerAuth = {
      enable = true;
      listenAddress = authListenAddress;
      token = {
        issuer = "https://cr.lea.science";
        expiration = 900;
        certificate = config.sops.secrets."docker_auth/certificate".path;
        key = config.sops.secrets."docker_auth/key".path;
      };
      users = {
        lea = {
          passwordFile =
            config.sops.secrets."docker_auth/users/lea/hashed-password".path;
        };
        garm = {
          passwordFile =
            config.sops.secrets."docker_auth/users/garm/hashed-password".path;
        };
        "" = { }; # Allow anonymous access
      };
      acl = [
        {
          match = { account = "/.+/"; };
          actions = [ "*" ];
          comment = "Logged in users have full access to everything";
        }
        {
          match = { account = ""; };
          actions = [ "pull" ];
          comment = "Anonymous users can pull everything";
        }
      ];
    };
    dockerRegistry = {
      enable = true;
      enableDelete = true;
      enableGarbageCollect = true;
      enableRedisCache = false;
      port = registryPort;
      extraConfig = {
        auth.token = {
          realm = "https://cr.lea.science/auth";
          service = "Docker registry";
          issuer = config.services.dockerAuth.token.issuer;
          rootcertbundle = config.services.dockerAuth.token.certificate;
        };
      };
    };
    nginx = {
      clientMaxBodySize = "0"; # Allow large uploads
      virtualHosts = {
        "cr.lea.science" = lib.mkMerge [
          nginxDockerRegistryVirtualHost
          {
            locations = {
              "/auth" = { proxyPass = "http://${authListenAddress}/auth"; };
            };
          }
        ];
        "gwas.science" = nginxDockerRegistryVirtualHost;
        "fmri.science" = nginxDockerRegistryVirtualHost;
      };
    };
  };
  sops = {
    secrets."docker_auth/users/lea/hashed-password" = { };
    secrets."docker_auth/users/garm/hashed-password" = { };
    secrets."docker_auth/certificate" = { mode = "0644"; };
    secrets."docker_auth/key" = {
      mode = "0440";
      owner = config.users.users.docker-auth.name;
      group = config.users.users.docker-auth.group;
    };
  };
}
