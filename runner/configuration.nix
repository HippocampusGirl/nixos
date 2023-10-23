{ config, pkgs, lib, ... }: {
  environment.shellAliases = { ll = "ls -lah"; };
  environment.systemPackages = with pkgs; [
    dig
    git
    htop
    lsof
    tailscale
    vim
    wget
  ];

  i18n = { defaultLocale = "en_US.UTF-8"; };

  networking = {
    hostName = "runner";
    hostId = "13413402";
    useDHCP = true;

    firewall = {
      enable = true;
      allowPing = false;
      allowedTCPPorts = [ 80 443 ] ++ config.services.openssh.ports;
      allowedUDPPorts = [ config.services.tailscale.port ];
      checkReversePath = "loose";
      trustedInterfaces = [ config.services.tailscale.interfaceName ];
    };
  };

  programs = {
    zsh.enable = true;
    command-not-found.enable = true;
  };

  services = {
    fail2ban.enable = true;
    # Adapted from https://xeiaso.net/blog/paranoid-nixos-2021-07-18
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
    tailscale = {
      enable = true;
    };
    usbguard.enable = true;
  };
  
  time = { timeZone = "Europe/Berlin"; };
}