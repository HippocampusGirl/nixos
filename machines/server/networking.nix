{
  networking = {
    hostId = "1ea1ea11";
    hostName = "server";

    firewall = { allowedTCPPorts = [ 80 443 ]; };

    enableIPv6 = true;
    interfaces = {
      ens3 = {
        useDHCP = false;
        ipv4.addresses = [{ address = "152.53.113.10"; prefixLength = 22; }];
        ipv6.addresses = [{ address = "2a0a:4cc0:80:481c::"; prefixLength = 64; }];
      };
    };
    defaultGateway = { address = "152.53.112.1"; interface = "ens3"; };
    defaultGateway6 = { address = "fe80::1"; interface = "ens3"; };

    useNetworkd = true;
  };
}
