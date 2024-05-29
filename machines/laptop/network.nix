{ config, pkgs, ... }:
let
  update-systemd-resolved =
    "${pkgs.update-systemd-resolved}/libexec/openvpn/update-systemd-resolved";

  defaultInterface = "eth0";
  dnsServer = "10.255.255.254";
in {
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
      fallbackDns = [ "10.255.255.254" ]; # dnsTunneling
    };
  };
  sops = {
    secrets."charite/openvpn/config" = { sopsFile = ./secrets.yaml; };
    secrets."charite/openvpn/credentials" = { sopsFile = ./secrets.yaml; };
  };
  systemd.services."wsl-dns-${defaultInterface}" = rec {
    description = "DNS configuration for ${defaultInterface}";
    bindsTo = [ "sys-subsystem-net-devices-${defaultInterface}.device" ];
    after = bindsTo;
    wantedBy = bindsTo;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      resolvectl dns '${defaultInterface}' '${dnsServer}'
    '';
    postStop = ''
      resolvectl revert '${defaultInterface}'
    '';
  };
  wsl.wslConf.network = { generateResolvConf = false; };
}
