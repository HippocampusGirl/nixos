{ config, pkgs, ... }: {
  imports = [ ../packages/docker-auth.nix ];
  services = {
    dockerAuth = {
      enable = true;
      listenAddress = "localhost:13451";
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
      port = 13450;
      extraConfig = {
        auth.token = {
          realm = "https://cr.lea.science/auth";
          service = "Docker registry";
          issuer = config.services.dockerAuth.token.issuer;
          rootcertbundle = config.services.dockerAuth.token.certificate;
        };
      };
    };
  };
}
