{ pkgs, ... }: {
  # Adapted from https://github.com/input-output-hk/cardano-parts/blob/main/flake/nixosModules/profile-mithril-relay.nix

  systemd.services.trafficserver = {
    # We would like to reload if any of the possible config modules are changed
    reloadIfChanged = true;
    serviceConfig.ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
  };

  services.trafficserver = {
    # enable = true;

    ipAllow = [
      {
        apply = "in";
        ip_addrs = "127.0.0.1";
        action = "allow";
        methods = "ALL";
      }
      {
        apply = "in";
        ip_addrs = "::1";
        action = "allow";
        methods = "ALL";
      }
    ];

    records = {
      proxy = {
        config = {
          proxy_name = "my_server";

          http = {
            server_ports = "13480 13480:ipv6";
            insert_squid_x_forwarded_for = 0;
          };

          # Disable reverse proxy
          reverse_proxy.enabled = 0;

          # Permit Traffic Server to process requests for hosts not explicitly configured in the remap rules
          url_remap = { pristine_host_hdr = 1; remap_required = 0; };
        };
      };
    };
  };
}
