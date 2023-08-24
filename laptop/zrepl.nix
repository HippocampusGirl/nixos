{ config, ... }: {
  services.zrepl = {
    enable = true;
    settings = {
      jobs = [{
        type = "snap";
        filesystems = { "z/lea" = true; };
        snapshotting = {
          type = "periodic";
          interval = "5m";
          prefix = "zrepl_";
        };
        pruning = {
          keep = [{
            type = "regex";
            regex = "^zrepl_.+";
          }];
        };
      }];
    };
  };
}
