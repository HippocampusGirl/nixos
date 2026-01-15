{
  # Adapted from https://xeiaso.net/blog/paranoid-nixos-2021-07-18
  services = {
    fail2ban.enable = true;
    openssh = {
      enable = true;
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
  };
  # Since we replaced "firewall.service" with "nftables.service", we need to
  # edit the fail2ban service to depend that instead
  systemd.services.fail2ban = { partOf = [ "nftables.service" ]; };
}
