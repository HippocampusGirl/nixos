# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ ... }: {
  imports = [
    ./cloudflare.nix
    ./docker-registry.nix
    ./garm.nix
    # Include the results of the hardware scan
    ./hardware-configuration.nix
    ./mattermost.nix
    ./nginx.nix
    ./upload-server.nix
    ./nix-remote.nix
    ./zrepl.nix
  ];

  boot = {
    # Use the systemd-boot EFI boot loader
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernel.sysctl = {
      "vm.dirty_background_ratio " = 5;
      "vm.dirty_ratio" = 10;
    };
    supportedFilesystems = [ "exfat" "zfs" ];
    tmp.cleanOnBoot = true;
    zfs = {
      devNodes = "/dev/disk/by-path";
      enableUnstable = true;
      requestEncryptionCredentials = true;
    };
  };

  documentation = {
    # Disable documentation to improve performance
    enable = false;
    nixos.enable = false;
  };

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
    defaultGateway.address = "5.45.108.1";
    defaultGateway6.address = "fe80::1";

    useNetworkd = true;
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;
    # If either of these paths does not exist immediately after boot, then 
    # sops-nix will fail and not decrypt any secrets. That means that the
    # the secrets will not be available when the users are generated. 
    # This can lead to login issues
    age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
    gnupg.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_rsa_key" ];
    # Specification of the secrets/
    secrets."users/lea/hashed-password" = {
      neededForUsers = true;
      sopsFile = ../../users/secrets.yaml;
    };
  };

  system = {
    # Enable automatic security updates
    autoUpgrade = {
      enable = true;
      allowReboot = false;
      dates = "daily UTC";
    };
    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    stateVersion = "24.05"; # Did you read the comment?
  };

  time = { timeZone = "Europe/Berlin"; };
}

