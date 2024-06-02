{ config, pkgs, ... }:
let
  endpoint = "cedb89.dns.nextdns.io";
  update-systemd-resolved = ''
    ${pkgs.update-systemd-resolved}/libexec/openvpn/update-systemd-resolved
    resolvectl dnsovertls $dev no'';
in
{
  services = {
    openvpn.servers."charite" = {
      config = ''
        config ${config.sops.secrets."charite/openvpn/config".path}
        auth-user-pass ${config.sops.secrets."charite/openvpn/credentials".path}
      '';
      up = update-systemd-resolved;
      down = update-systemd-resolved;
    };
    resolved = {
      enable = true;
      dnssec = "allow-downgrade";
      dnsovertls = "true";
      extraConfig = ''
        [Resolve]
        DNS=45.90.28.0#${endpoint}
        DNS=2a07:a8c0::#${endpoint}
        DNS=45.90.30.0#${endpoint}
        DNS=2a07:a8c1::#${endpoint}

        DNSStubListenerExtra=udp:127.0.0.1:9953
        DNSStubListenerExtra=udp:[::1]:9953
      '';
      fallbackDns = [
        "1.1.1.1#one.one.one.one"
        "2606:4700:4700::1111#one.one.one.one"
        "1.0.0.1#one.one.one.one"
        "2606:4700:4700::1001#one.one.one.one"
        "8.8.8.8#dns.google"
        "2001:4860:4860::8888#dns.google"
        "8.8.4.4#dns.google"
        "2001:4860:4860::8844#dns.google"
      ];
    };
  };
  sops = {
    secrets."charite/openvpn/config" = { sopsFile = ./secrets.yaml; };
    secrets."charite/openvpn/credentials" = { sopsFile = ./secrets.yaml; };
  };
  wsl.wslConf.network = { generateResolvConf = false; };
}
