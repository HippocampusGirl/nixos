{ config, ... }: {
  imports = [ ../packages/tailscale-cert.nix ];
  networking.firewall.trustedInterfaces =
    [ config.services.tailscale.interfaceName ];
  services = {
    tailscale = {
      enable = true;
      openFirewall = true;
      port = 13475;
      useRoutingFeatures = "both";
    };
    tailscale-cert.enable = true;
  };
  systemd.services.tailscaled =
    let depends-on = [ "network-online.target" "systemd-resolved.service" ];
    in {
      after = depends-on;
      wants = depends-on;
    };
}
