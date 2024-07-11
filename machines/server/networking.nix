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
    secrets."denbi/life-science-login" = { };
    secrets."denbi/private-key" = { };
  };
  systemd.services."sshuttle" = {
    enable = true;
    description = "sshuttle tunnel to denbi";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "forking";
      ExecStart = ''${pkgs.writeShellScriptBin "start-sshuttle" ''
        ${pkgs.sshuttle}/bin/sshuttle \
          --ssh-cmd="ssh -i ${config.sops.secrets."denbi/private-key".path}" \
          --remote="$(cat ${config.sops.secrets."denbi/life-science-login".path})@denbi-jumphost-01.bihealth.org" \
          172.16.0.0/15
      ''}/bin/start-sshuttle'';
    };
  };
}