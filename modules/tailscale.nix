{ config, pkgs, ... }: {
  networking.firewall.trustedInterfaces = [ config.services.tailscale.interfaceName ];
  networking.networkmanager.unmanaged = [ config.services.tailscale.interfaceName ];
  services = {
    tailscale = {
      enable = true;
      package = pkgs.tailscale;

      openFirewall = true;
      port = 13475;

      useRoutingFeatures = "both";

      extraDaemonFlags = [ "--no-logs-no-support" ];
    };
  };
  systemd.services.tailscaled =
    let depends-on = [ "network-online.target" "systemd-resolved.service" ];
    in {
      after = depends-on;
      wants = depends-on;
    };
  systemd.services.tailscale-wait-online = {
    serviceConfig = {
      Type = "oneshot";
      # See https://github.com/tailscale/tailscale/issues/11504#issuecomment-2692132659
      ExecStart = "${pkgs.coreutils}/bin/timeout 60s ${pkgs.bash}/bin/bash -c \'until ${pkgs.tailscale}/bin/tailscale status --peers=false; do ${pkgs.coreutils}/bin/sleep 1; done\'";
    };
    wantedBy = [ "network-online.target" ];
    before = [ "network-online.target" ];
    after = [ "tailscaled.service" ];
    requires = [ "tailscaled.service" ];
  };
}
