{ config, ... }: {
  # Adapted from https://xeiaso.net/blog/paranoid-nixos-2021-07-18
  networking = {
    firewall = {
      enable = true;
      allowPing = false;
      allowedTCPPorts = [ 80 443 ] ++ config.services.openssh.ports;
      allowedUDPPorts = [ config.services.tailscale.port ];
      checkReversePath = "loose";
      trustedInterfaces = [ config.services.tailscale.interfaceName ];
    };
  };
  services = {
    fail2ban.enable = true;
    openssh = {
      enable = true;
      ports = [ 13422 ];
      allowSFTP = false; # We don't need SFTP
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
      extraConfig = ''
        AllowTcpForwarding yes
        X11Forwarding no
        AllowAgentForwarding no
        AllowStreamLocalForwarding no
        AuthenticationMethods publickey
      '';
    };
    usbguard.enable = true;
  };
}