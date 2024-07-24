{ pkgs, config, ... }: {
  networking = {
    hostId = "1ea1ea11";
    hostName = "server";

    firewall = { allowedTCPPorts = [ 80 443 ]; };

    enableIPv6 = true;
    interfaces = {
      ens3 = {
        useDHCP = false;
        ipv4.addresses = [{ address = "5.45.110.175"; prefixLength = 22; }];
        ipv6.addresses = [{ address = "2a03:4000:6:2187::"; prefixLength = 64; }];
      };
    };
    defaultGateway = { address = "5.45.108.1"; interface = "ens3"; };
    defaultGateway6 = { address = "fe80::1"; interface = "ens3"; };

    useNetworkd = true;
  };
  sops = {
    secrets."denbi/private-key" = { };
  };
  systemd.services."sshuttle" =
    let
      domain = "bihealth.org";
      ssh-server = "denbi-jumphost-01.${domain}";
      dns-server = "127.254.254.53";
    in
    {
      enable = true;
      description = "sshuttle tunnel to denbi";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "notify";
        KillMode = "mixed";
        KillSignal = "SIGINT";

        ExecStartPre = [
          "${pkgs.iproute2}/bin/ip route add local default dev lo table 100"
          "${pkgs.iproute2}/bin/ip -6 route add local default dev lo table 100"

          "${pkgs.iproute2}/bin/ip rule add fwmark 0x01 lookup 100"
          "${pkgs.iproute2}/bin/ip -6 rule add fwmark 0x01 lookup 100"

          "${pkgs.iproute2}/bin/ip link add sshuttle0 type dummy"
        ];
        ExecStart = [
          ''${pkgs.sshuttle}/bin/sshuttle -vvv \
              --method="tproxy" \
              --disable-ipv6 \
              --ssh-cmd="ssh -i ${config.sops.secrets."denbi/private-key".path}" \
              --remote="hippocampusgirl@${ssh-server}" \
              --ns-hosts="${dns-server}" \
              172.16.0.0/15''
        ];
        # https://github.com/sshuttle/sshuttle/issues/688#issuecomment-971833099
        ExecStartPost = [
          "${pkgs.systemd}/bin/resolvectl dns sshuttle0 ${dns-server}"
          "${pkgs.systemd}/bin/resolvectl domain sshuttle0 ${domain}"
          "${pkgs.systemd}/bin/resolvectl default-route sshuttle0 false"
          "${pkgs.systemd}/bin/resolvectl dnsovertls sshuttle0 no"

          "${pkgs.iproute2}/bin/ip link set sshuttle0 up"
          "${pkgs.iproute2}/bin/ip addr add dev sshuttle0 10.0.0.1/32"
        ];
        ExecStopPost = [
          "${pkgs.iproute2}/bin/ip route del local default dev lo table 100"
          "${pkgs.iproute2}/bin/ip -6 route del local default dev lo table 100"
          "${pkgs.iproute2}/bin/ip link del sshuttle0"
        ];
      };
    };
}
