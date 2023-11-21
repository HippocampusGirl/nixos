{ config, pkgs, ... }: {
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
  systemd.services.tailscaled.after =
    [ "network-online.target" "systemd-resolved.service" ];
}
