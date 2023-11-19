{ config, ... }:
let port = 13481;
in {
  services = {
    upload-server = {
      inherit port;
      enable = true;
      publicKeyFile = config.sops.secrets."upload-server/public-key".path;
      s3 = {
        endpointFile = config.sops.secrets."upload-server/s3/endpoint".path;
        accessKeyIdFile =
          config.sops.secrets."upload-server/s3/access-key-id".path;
        secretAccessKeyFile =
          config.sops.secrets."upload-server/s3/secret-access-key".path;
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
  };
  sops = {
    secrets."upload-server/public-key" = { };
    secrets."upload-server/s3/endpoint" = { };
    secrets."upload-server/s3/access-key-id" = { };
    secrets."upload-server/s3/secret-access-key" = { };
  };
}
