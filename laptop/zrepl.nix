{ config, ... }: {
  services.zrepl = {
    enable = true;
    settings = {
      jobs = [{
        name = "work";
        type = "snap";
        filesystems = { "z/work" = true; };
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