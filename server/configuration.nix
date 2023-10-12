# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }: {
  imports = [
    ./docker-registry.nix
    ./garm.nix
    # Include the results of the hardware scan
    ./hardware-configuration.nix
    ./nginx.nix
    ./password.nix
    ./tailscale.nix
    ../users/lea.nix
  ];

  boot = {
    # Use the systemd-boot EFI boot loader
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = [ "zfs" ];
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    kernel.sysctl = {
      "vm.dirty_background_ratio " = 5;
      "vm.dirty_ratio" = 10;
    };
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

  environment.persistence."/persist" = {
    directories = [
      "/var/lib" # System service persistent data
      "/var/log" # The place that journald logs to
    ];
    files = [
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/machine-id"
    ];
  };
  environment.shellAliases = { ll = "ls -lah"; };
  environment.systemPackages = with pkgs; [
    dig
    git
    htop
    jq
    lsof
    tailscale
    vim
    wget
  ];

  i18n = { defaultLocale = "en_US.UTF-8"; };

  networking = {
    hostName = "server";
    hostId = "13413401";
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

  nix = {
    # Allow use by wheel group
    settings.allowed-users = [ "@wheel" ];
    # Enable garbage collection every week
    gc = {
      automatic = true;
      dates = "Monday 01:00 UTC";
      options = "--delete-older-than 7d";
    };
    # Run garbage collection when disk is almost full
    extraOptions = ''
      min-free = ${toString (512 * 1024 * 1024)}
      experimental-features = nix-command flakes impure-derivations
    '';
  };

  programs = {
    zsh.enable = true;
    command-not-found.enable = true;
  };

  time = { timeZone = "Europe/Berlin"; };

  security = {
    acme = {
      acceptTerms = true;
      defaults.email = "lea@lea.science";
    };
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

    usbguard.enable = true;
  };

  sops = {
    defaultSopsFile = ../secrets.yaml;
    # If either of these paths does not exist immediately after boot, then 
    # sops-nix will fail and not decrypt any secrets. That means that the
    # the secrets will not be available when the users are generated. 
    # This can lead to login issues
    age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
    gnupg.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_rsa_key" ];
    # Specification of the secrets/
    secrets."users/root/hashed-password" = { neededForUsers = true; };
    secrets."users/lea/hashed-password" = { neededForUsers = true; };
    secrets."garm/jwt_auth/secret" = { };
    secrets."garm/database/passphrase" = { };
    secrets."garm/github/hippocampusgirl/token" = { };
    secrets."docker_auth/users/lea/hashed-password" = { };
    secrets."docker_auth/users/garm/hashed-password" = { };
    secrets."docker_auth/certificate" = { mode = "0644"; };
    secrets."docker_auth/key" = {
      mode = "0440";
      owner = config.users.users.docker-auth.name;
      group = config.users.users.docker-auth.group;
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
    stateVersion = "23.05"; # Did you read the comment?
  };

  users = {
    # Do not allow passwords to be changed
    mutableUsers = false;
    users.root = {
      subUidRanges = lib.mkForce [{
        startUid = 10000000;
        count = 1000000;
      }];
      subGidRanges = lib.mkForce [{
        startGid = 10000000;
        count = 1000000;
      }];
    };
  };

  virtualisation = {
    lxc = {
      enable = true;
      lxcfs = { enable = true; };
    };
    lxd = {
      enable = true;

      # This turns on a few sysctl settings that the LXD documentation recommends
      # for running in production.
      recommendedSysctlSettings = true;
    };
  };

  zramSwap = {
    # Enable memory compression
    enable = true;
    memoryPercent = 150;
  };
}

