{ lib, pkgs, ... }:
{
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
  config = {
    services.zrepl.package = pkgs.zrepl.overrideAttrs (_: {
      patches = [
        ./zrepl-max-recv-msg-size.patch
      ];
    });
  };
}
