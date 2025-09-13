{ config, ... }:
let
  cfg = config.services.zrepl;
  ca = "/etc/ssl/certs/ca-certificates.crt";
  cert = config.services.tailscale-cert.certFile;
  key = config.services.tailscale-cert.keyFile;
  client_cns = [ "laptop.dzo-owl.ts.net" ];
in
{
  services.zrepl = {
    enable = true;
    settings = {
      jobs = [
        {
          name = "sink";
          type = "sink";
          root_fs = "z";
          serve = {
            type = "tls";
            listen = "server.dzo-owl.ts.net:${toString (cfg.sinkPort)}";
            inherit ca cert key client_cns;
          };
          recv.placeholder.encryption = "inherit";
        }
        {
          name = "source";
          type = "source";
          filesystems = {
            "z/lea" = true;
            "z/persist" = true;
            "z/postgres" = true;
            "z/www" = true;
          };
          serve = {
            type = "tls";
            listen = "server.dzo-owl.ts.net:${toString (cfg.sourcePort)}";
            inherit ca cert key client_cns;
          };
          send = { encrypted = false; };
          snapshotting = {
            type = "periodic";
            interval = "5m";
            prefix = "zrepl_";
          };
        }
      ];
    };
  };
}
