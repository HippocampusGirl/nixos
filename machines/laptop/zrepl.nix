{ config, ... }: {
  services.zrepl = {
    enable = true;
    settings = {
      jobs = [{
        name = "push";
        type = "push";
        filesystems = { "z/work" = true; };
        connect = {
          type = "tls";
          address = "home.dzo-owl.ts.net:13427";
          server_cn = "home.dzo-owl.ts.net";
          ca = "/etc/ssl/certs/ca-certificates.crt";
          cert = config.services.tailscale-cert.certFile;
          key = config.services.tailscale-cert.keyFile;
        };
        snapshotting = {
          type = "periodic";
          interval = "5m";
          prefix = "zrepl_";
        };
        send = { encrypted = false; };
        pruning = {
          keep_sender = [
            { type = "not_replicated"; }
            {
              type = "regex";
              regex = "^zrepl_.+";
            }
          ];
          keep_receiver = [{
            type = "regex";
            regex = "^zrepl_.+";
          }];
        };
      }];
    };
  };
}
