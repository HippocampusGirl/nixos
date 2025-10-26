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
in
{
  imports = [ ../../packages/docker-auth.nix ];
  services = {
    dockerAuth = {
      enable = true;
      listenAddress = authListenAddress;
      token = {
        issuer = "https://cr.lea.science";
        expiration = 900;
        certificate = config.sops.secrets."docker-auth/certificate".path;
        key = config.sops.secrets."docker-auth/key".path;
        jwks = config.sops.secrets."docker-auth/jwks".path;
      };
      users = {
        lea = {
          passwordFile =
            config.sops.secrets."docker-auth/users/lea/hashed-password".path;
        };
        garm = {
          passwordFile =
            config.sops.secrets."docker-auth/users/garm/hashed-password".path;
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
          jwks = config.services.dockerAuth.token.jwks;
        };
      };
      # package = distribution;
      # storagePath = null;
      # extraConfig = {
      #   storage = {
      #     s3 = {
      #       chunksize = 104857600;
      #     };
      #   };
      # };
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
    secrets."docker-auth/users/lea/hashed-password" = { };
    secrets."docker-auth/users/garm/hashed-password" = { };
    secrets."docker-auth/certificate" = { mode = "0644"; };
    secrets."docker-auth/jwks" = { mode = "0644"; };
    secrets."docker-auth/key" = {
      mode = "0440";
      owner = config.users.users.docker-auth.name;
      group = config.users.users.docker-auth.group;
    };
    secrets."docker-registry/environment" = { };
  };
  systemd.services.docker-registry.serviceConfig = {
    Environment = [ "OTEL_TRACES_EXPORTER=none" ];
    #   EnvironmentFile = config.sops.secrets."docker-registry/environment".path;
  };
  systemd.services.docker-registry-garbage-collect = {
    script = lib.mkForce ''
      ${config.services.dockerRegistry.package}/bin/registry garbage-collect --delete-untagged ${config.services.dockerRegistry.configFile}
      /run/current-system/systemd/bin/systemctl restart docker-registry.service
    '';
  };
}
