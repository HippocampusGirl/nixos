{
  networking = {
    hostId = "1ea1ea11";
    hostName = "server";

    firewall = { allowedTCPPorts = [ 80 443 ]; };

    enableIPv6 = true;
    interfaces = {
      ens3 = {
        useDHCP = false;
        ipv4.addresses = [{ address = "159.195.57.16"; prefixLength = 22; }];
        ipv6.addresses = [{ address = "2a0a:4cc0:c1:e086::"; prefixLength = 64; }];
      };
    };
    defaultGateway = { address = "159.195.56.1"; interface = "ens3"; };
    defaultGateway6 = { address = "fe80::1"; interface = "ens3"; };

    useNetworkd = true;
  };
}
