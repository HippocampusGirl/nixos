{ lib, config, pkgs, ... }: {
  imports = [ ./mta-sts.nix ];

  services = {
    nginx = {
      enable = true;
      enableReload = true;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedBrotliSettings = true;
      recommendedGzipSettings = true;
      recommendedZstdSettings = true;
      recommendedProxySettings = true;
      virtualHosts = {
        "server.lea.science" = {
          forceSSL = true;
          enableACME = true;
          locations."/".root = "/www";
        };
      };
    };
  };
}
