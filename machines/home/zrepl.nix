{ config, lib, ... }:
let cfg = config.services.zrepl;
in {
  config = {
    services.zrepl = {
      enable = true;
      settings = {
        jobs = [{
          name = "sink";
          type = "sink";
          root_fs = "z";
          serve = {
            type = "tls";
            listen = "home.dzo-owl.ts.net:${toString (cfg.sinkPort)}";
            ca = "/etc/ssl/certs/ca-certificates.crt";
            cert = config.services.tailscale-cert.certFile;
            key = config.services.tailscale-cert.keyFile;
            client_cns = [ "laptop.dzo-owl.ts.net" ];
          };
        }];
      };
    };
    systemd.services.zrepl = {
      after = [ "tailscaled.service" "sys-subsystem-net-devices-tailscale0.device" ];
    };
  };
}
