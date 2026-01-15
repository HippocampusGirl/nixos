{ config, ... }: {
  services.usbguard.enable = true;
  networking = {
    firewall = {
      enable = true;
      allowPing = false;
      allowedTCPPorts = config.services.openssh.ports;
      checkReversePath = "loose";
    };
    nftables.enable = true;
  };
}
