{ config, pkgs, ... }: {
  imports = [ ../packages/garm.nix ];
  services = {
    garm = {
      enable = true;
      logStreamer.enable = true;
      metrics.enable = false;
      callbackUrl = "https://garm.lea.science/api/v1/callbacks/status";
      metadataUrl = "https://garm.lea.science/api/v1/metadata";
      jwtAuth.secretFile = config.sops.secrets."garm/jwt_auth/secret".path;
      apiServer = {
        bind = "127.0.0.1";
        port = 13464;
        tls.enable = false;
      };
      lxd.instanceType = "container";
      database.passphraseFile =
        config.sops.secrets."garm/database/passphrase".path;
      github."HippocampusGirl".tokenFile =
        config.sops.secrets."garm/github/hippocampusgirl/token".path;
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
}
