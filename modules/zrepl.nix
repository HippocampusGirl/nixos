{ config, lib, ... }:
let cfg = config.services.zrepl;
in {
  options = with lib; {
    services.zrepl = {
      sinkPort = mkOption {
        type = types.int;
        description = "The port to listen on.";
        default = 13427;
      };
      sourcePort = mkOption {
        type = types.int;
        description = "The port to listen on.";
        default = 13428;
      };
    };
  };
}
