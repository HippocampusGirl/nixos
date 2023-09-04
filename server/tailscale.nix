{ config, pkgs, ... }: {
  imports = [ ../packages/tailscale-cert.nix ];
  services = {
    tailscale = {
      enable = true;
      port = 13475;
    };
    tailscale-cert.enable = true;
  };
}
