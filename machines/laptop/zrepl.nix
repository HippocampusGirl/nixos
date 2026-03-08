{ config, ... }:
let
  filesystems = { "z/work" = true; };
in
with config.services.zrepl.base; {
  services.zrepl = {
    enable = true;
    settings = {
      jobs = [
        # The snap job takes snapshots of work every 5 minutes
        {
          name = "snap";
          type = "snap";
          snapshotting = {
            type = "periodic";
            interval = "5m";
            prefix = "zrepl_";
          };
          inherit filesystems;
          pruning.keep = keepForever;
        }
        {
          name = "source_home";
          type = "source";
          inherit filesystems snapshotting;
          serve = {
            type = "tls";
            listen = "laptop.dzo-owl.ts.net:${toString (sourcePort)}";
            inherit ca cert key;
            client_cns = [ "home.dzo-owl.ts.net" ];
          };
        }
        {
          name = "source_server";
          type = "source";
          inherit filesystems send snapshotting;
          serve = {
            type = "tls";
            listen = "laptop.dzo-owl.ts.net:${toString (sourcePort + 1)}";
            inherit ca cert key;
            client_cns = [ "server.dzo-owl.ts.net" ];
          };
        }
      ];
    };
  };
  systemd.services.zrepl = {
    after = [ "tailscaled.service" "sys-subsystem-net-devices-tailscale0.device" ];
  };
}
