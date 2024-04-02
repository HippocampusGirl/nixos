{ pkgs, config, lib, ... }:
let
  cfg = config.services.tailscale-cert;
  tailscale = "/mnt/c/Program\\ Files/Tailscale/tailscale.exe";

  basePath = "/var/lib/tailscale/certs";

  temporaryCertFile = "/mnt/c/Users/Lea/WSL/cert.pem";
  temporaryKeyFile = "/mnt/c/Users/Lea/WSL/key.pem";
in {
  options = with lib; {
    services.tailscale-cert = {
      keyFile = mkOption {
        type = types.path;
        description = "The path to the tailscale key.";
        default = "${basePath}/key.pem";
      };
      certFile = mkOption {
        type = types.path;
        description = "The path to the tailscale certificate.";
        default = "${basePath}/cert.pem";
      };
    };
  };

  config = {
    systemd.services.tailscale-cert = {
      after = [ "network.target" "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      path = with pkgs; [ dig ];

      serviceConfig = { Type = "oneshot"; };

      script = ''
        # Generate certificates
        ip_address=$(${tailscale} ip -1)
        domain_name=$(dig +noall +answer +short -x ''${ip_address} | sed -e 's/.$//')
        ${tailscale} cert \
            --cert-file $(/bin/wslpath -w ${temporaryCertFile}) \
            --key-file  $(/bin/wslpath -w ${temporaryKeyFile}) \
            ''${domain_name}
        # Move certificates to the correct location
        mkdir --parents ${basePath}
        mv ${temporaryCertFile} ${cfg.certFile}
        mv ${temporaryKeyFile} ${cfg.keyFile}
        # Set permissions
        chown root:root ${cfg.certFile} ${cfg.keyFile}
        chmod 644 ${cfg.certFile}
        chmod 600 ${cfg.keyFile}
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
