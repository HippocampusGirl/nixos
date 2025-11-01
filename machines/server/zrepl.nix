{ config, ... }:
let
  filesystems = {
    "z/lea" = true;
    "z/persist" = true;
    "z/postgres" = true;
    "z/www" = true;
  };
in
with config.services.zrepl.base; {
  services.zrepl = {
    enable = true;
    settings = {
      jobs = [
        {
          name = "snap";
          type = "snap";
          inherit filesystems;
          snapshotting = {
            type = "periodic";
            interval = "5m";
            prefix = "zrepl_";
          };
          pruning.keep = keep;
        }
        {
          name = "source_laptop";
          type = "source";
          inherit filesystems send snapshotting;
          serve = {
            type = "tls";
            listen = "server.dzo-owl.ts.net:${toString (sourcePort)}";
            inherit ca cert key;
            client_cns = [ "laptop.dzo-owl.ts.net" ];
          };
        }
        {
          name = "source_home";
          type = "source";
          inherit filesystems send snapshotting;
          serve = {
            type = "tls";
            listen = "server.dzo-owl.ts.net:${toString (sourcePort + 1)}";
            inherit ca cert key;
            client_cns = [ "home.dzo-owl.ts.net" ];
          };
        }
        {
          name = "pull_laptop";
          type = "pull";
          connect = {
            type = "tls";
            address = "laptop.dzo-owl.ts.net:${toString (sourcePort + 1)}";
            server_cn = "laptop.dzo-owl.ts.net";
            inherit ca cert key;
          };
          inherit replication interval recv;
          conflict_resolution = { initial_replication = "most_recent"; };
          root_fs = "z/laptop.dzo-owl.ts.net";
          pruning = {
            keep_sender = keepForever;
            keep_receiver = keep;
          };
        }
      ];
    };
  };
}
