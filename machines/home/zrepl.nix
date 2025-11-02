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
          {
            name = "push_zerofs";
            type = "push";
            connect = {
              type = "local";
              listener_name = "zerofs_sink";
              client_identity = "home.dzo-owl.ts.net";
            };
            filesystems = {
              # "z/dropbox" = true;
              # "z/laptop.dzo-owl.ts.net/z/work" = true;
              "z/persist" = true;
              # "z/server.dzo-owl.ts.net/z/persist" = true;
              # "z/server.dzo-owl.ts.net/z/postgres" = true;
              # "z/server.dzo-owl.ts.net/z/work" = true;
              # "z/server.dzo-owl.ts.net/z/www" = true;
            };
            inherit send snapshotting conflict_resolution;
            replication = {
              concurrency = replication.concurrency;
              protection = {
                initial = "guarantee_resumability";
                # Downgrade protection to guarantee_incremental which uses zfs bookmarks instead of zfs holds.
                # Thus, when we yank out the backup drive during replication
                # - we might not be able to resume the interrupted replication step because the partially received `to` snapshot of a `from`->`to` step may be pruned any time
                # - but in exchange we get back the disk space allocated by `to` when we prune it
                # - and because we still have the bookmarks created by `guarantee_incremental`, we can still do incremental replication of `from`->`to2` in the future
                incremental = "guarantee_incremental";
              };
            };
            pruning = {
              keep_sender = keepForever;
              keep_receiver = keepHourly;
            };
          }
          {
            name = "sink_zerofs";
            type = "sink";
            root_fs = "y";
            serve = {
              type = "local";
              listener_name = "zerofs_sink";
            };
            inherit recv;
          }
        ];
      };
    };
    systemd.services.zrepl = {
      after = [ "tailscaled.service" "sys-subsystem-net-devices-tailscale0.device" ];
    };
  };
}
