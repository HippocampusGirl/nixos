{ config, pkgs, ... }:
let
  cfg = config.services.zrepl;
  ca = "/etc/ssl/certs/ca-certificates.crt";
  cert = config.services.tailscale-cert.certFile;
  key = config.services.tailscale-cert.keyFile;
  regex = "^zrepl_.*";
  keep = [{
    type = "grid";
    grid = "1x1d(keep=all) | 24x1h | 7x1d | 12x30d";
    inherit regex;
  }];
  keepForever = [{
    type = "regex";
    inherit regex;
  }];
  replication = {
    concurrency = {
      size_estimates = 20;
      steps = 20;
    };
  };
  conflict_resolution = { initial_replication = "all"; };
  send = { encrypted = false; };
  snapshotting = { type = "manual"; };
  wakeupJobs = pkgs.writeShellApplication {
    name = "wakeup-jobs";
    runtimeInputs = [ config.services.zrepl.package ];
    text = ''
      if [ "$ZREPL_DRYRUN" = "true" ]
      then 
        DRYRUN="echo DRYRUN: "
      else
        DRYRUN=""
      fi

      case "$ZREPL_HOOKTYPE" in
          pre_snapshot)
              exit 0
              ;;
          post_snapshot)
              $DRYRUN zrepl signal wakeup push_home || true
              $DRYRUN zrepl signal wakeup push_server || true
              exit 0
              ;;
          *)
              printf 'Unrecognized hook type: %s\n' "$ZREPL_HOOKTYPE"
              exit 255
              ;;
      esac
    '';
  };
in
{
  services.zrepl = {
    enable = true;
    settings = {
      jobs = [
        # The snap job takes snapshots of work every 5 minutes
        {
          name = "snap";
          type = "snap";
          filesystems = { "z/work" = true; };
          snapshotting = {
            type = "periodic";
            interval = "5m";
            prefix = "zrepl_";
            hooks = [{
              type = "command";
              path = "${wakeupJobs}/bin/wakeup-jobs";
              err_is_fatal = false;
            }];
          };
          pruning.keep = keepForever;
        }
        # The home has a lot of disk space, so we keep hourly snapshots
        # for one hundred years
        {
          name = "push_home";
          type = "push";
          filesystems = { "z/work" = true; };
          connect = {
            type = "tls";
            address = "home.dzo-owl.ts.net:${toString (cfg.sinkPort)}";
            server_cn = "home.dzo-owl.ts.net";
            inherit ca cert key;
          };
          conflict_resolution = { initial_replication = "all"; };
          inherit replication send snapshotting;
          pruning = {
            keep_sender = keepForever;
            keep_receiver = [{
              type = "grid";
              grid = "1x1d(keep=all) | 1000000x1h";
              inherit regex;
            }];
          };
        }
        # The server does not have much disk space, so we keep only a limited
        # snapshot history there
        {
          name = "push_server";
          type = "push";
          filesystems = { "z/work" = true; };
          connect = {
            type = "tls";
            address = "server.dzo-owl.ts.net:${toString (cfg.sinkPort)}";
            server_cn = "server.dzo-owl.ts.net";
            inherit ca cert key;
          };
          conflict_resolution = { initial_replication = "most_recent"; };
          inherit replication send snapshotting;
          pruning = {
            keep_sender = keepForever;
            keep_receiver = keep;
          };
        }
        # The pull job pulls snapshots from the server every ten minutes
        {
          name = "pull";
          type = "pull";
          connect = {
            type = "tls";
            address = "server.dzo-owl.ts.net:${toString (cfg.sourcePort)}";
            server_cn = "server.dzo-owl.ts.net";
            inherit ca cert key;
          };
          inherit conflict_resolution replication;
          recv.placeholder.encryption = "inherit";
          root_fs = "z/server.dzo-owl.ts.net";
          interval = "10m";
          pruning = {
            keep_sender = [{ type = "not_replicated"; }] ++ keep;
            keep_receiver = keep;
          };
        }
      ];
    };
  };
  systemd.services.zrepl = {
    after = [ "tailscaled.service" "sys-subsystem-net-devices-tailscale0.device" ];
  };
}
