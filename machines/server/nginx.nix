{
  imports = [ ./mta-sts.nix ];

  services = {
    fail2ban = {
      enable = true;
      jails = {
        "nginx-http-auth".enabled = true;
        "nginx-botsearch".enabled = true;
      };
    };
  };
  nginx = {
    enable = true;
    enableReload = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;
    virtualHosts = {
      "server.lea.science" = {
        forceSSL = true;
        enableACME = true;
        locations."/".root = "/www/server.lea.science";
      };
      "fmri.science" = {
        forceSSL = true;
        enableACME = true;
        locations."/".root = "/www/fmri.science";
      };
    };
  };
};
}
