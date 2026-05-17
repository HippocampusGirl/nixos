{ lib, pkgs, config, ... }:
{
  options = with lib; {
    services.zrepl = {
      base = mkOption {
        type = types.attrs;
      };
    };
  };
  config = {
    sops = {
      secrets."pki/crt" = { };
      secrets."pki/key" = { };
    };
    services.zrepl = {
      package = pkgs.zrepl.overrideAttrs (_: {
        patches = [
          ./zrepl-max-recv-msg-size.patch
        ];
      });

      base = rec {
        ca = ../ca.crt;
        cert = config.sops.secrets."pki/crt".path;
        key = config.sops.secrets."pki/key".path;

        sinkPort = 13427;
        sourcePort = 13428;

        regex = "^zrepl_";
        keep = [{
          type = "grid";
          grid = "1x1d(keep=all) | 24x1h | 7x1d | 12x30d";
          inherit regex;
        }];
        # Keep hourly snapshots for one hundred years
        keepHourly = [{
          type = "grid";
          grid = "1x1d(keep=all) | 1000000x1h";
          inherit regex;
        }];
        keepForever = [{
          type = "regex";
          inherit regex;
        }];

        replication.concurrency = {
          size_estimates = 20;
          steps = 20;
        };
        conflict_resolution = { initial_replication = "all"; };

        send = { encrypted = false; };
        recv.placeholder.encryption = "inherit";

        snapshotting = { type = "manual"; };

        interval = "10m";
      };
    };
  };
}
