{
  imports = [ ./mta-sts.nix ];

  services = {
    fail2ban = {
      enable = true;
      jails.nginx-auth = ''
        enabled  = true
        port     = http,https
        filter   = nginx-noagent
        backend  = auto
        maxretry = 1
        logpath  = %(nginx_access_log)s
        action   = iptables-multiport[port="http,https"]
      '';
    };
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
