# Adapted from https://github.com/X01A/nixos/blob/master/modules/network/tailscale/cert.nix
{ config, lib, pkgs, ... }:
with lib;
let cfg = config.services.tailscale-cert;
in {
  options = {
    services.tailscale-cert = {
      enable = mkEnableOption "Enable tailscale cert service";

      basePath = mkOption {
        type = types.path;
        description = "The directory to store the tailscale certificates.";
        default = "/var/lib/tailscale/certs";
      };
      keyFile = mkOption {
        type = types.path;
        description = "The path to the tailscale key.";
        default = "${cfg.basePath}/key.pem";
      };
      certFile = mkOption {
        type = types.path;
        description = "The path to the tailscale certificate.";
        default = "${cfg.basePath}/cert.pem";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.tailscale-cert = {
      after = [ "network.target" "network-online.target" "tailscaled.service" ];
      wants = [ "tailscaled.service" ];
      requires = [ "tailscaled.service" ];
      wantedBy = [ "multi-user.target" ];

      path = with pkgs; [ dig tailscale ];

      serviceConfig = {
        Type = "oneshot";
        ProtectSystem = "strict";
        ReadWritePaths = [ cfg.basePath ];
        PrivateTmp = true;
        WorkingDirectory = cfg.basePath;
        NoNewPrivileges = true;
        PrivateDevices = true;
        ProtectClock = true;
        ProtectHome = true;
        ProtectHostname = true;
      };

      script = ''
        ip_address=$(tailscale ip -1)
        domain_name=$(dig +noall +answer +short -x ''${ip_address} | sed -e 's/.$//')
        tailscale cert --cert-file ${cfg.certFile} --key-file ${cfg.keyFile} ''${domain_name}
      '';
    };

    systemd.timers.tailscale-cert = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "weekly";
        Unit = "tailscale-cert.service";
        Persistent = "yes";
        RandomizedDelaySec = "24h";
      };
    };
  };
}
