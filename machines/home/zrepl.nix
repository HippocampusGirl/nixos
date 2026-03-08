{ config, ... }:
with config.services.zrepl.base; {
  config = {
    services.zrepl = {
      enable = true;
      settings = {
        jobs = [
          {
            name = "snap";
            type = "snap";
            filesystems = { "z/persist" = true; };
            snapshotting = {
              type = "periodic";
              interval = "5m";
              prefix = "zrepl_";
            };
            pruning.keep = keep;
          }
          {
            name = "pull_laptop";
            type = "pull";
            connect = {
              type = "tls";
              address = "laptop.dzo-owl.ts.net:${toString (sourcePort)}";
              server_cn = "laptop.dzo-owl.ts.net";
              inherit ca cert key;
            };
            inherit conflict_resolution replication interval recv;
            root_fs = "z/laptop.dzo-owl.ts.net";
            pruning = {
              keep_sender = [{ type = "not_replicated"; }] ++ keep;
              # Keep hourly snapshots for one hundred years
              keep_receiver = keepHourly;
            };
          }
          {
            name = "pull_server";
            type = "pull";
            connect = {
              type = "tls";
              address = "server.dzo-owl.ts.net:${toString (sourcePort + 1)}";
              server_cn = "server.dzo-owl.ts.net";
              inherit ca cert key;
            };
            inherit conflict_resolution replication interval recv;
            root_fs = "z/server.dzo-owl.ts.net";
            pruning = {
              keep_sender = keepForever;
              keep_receiver = keep;
            };
          }
        ];
      };
    };
    systemd.services.zrepl = {
      after = [ "tailscaled.service" "sys-subsystem-net-devices-tailscale0.device" ];
    };
  };
}
