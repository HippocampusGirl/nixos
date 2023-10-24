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
  ];

  boot = {
    # Use the systemd-boot EFI boot loader
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    kernel.sysctl = {
      "vm.dirty_background_ratio " = 5;
      "vm.dirty_ratio" = 10;
    };
    supportedFilesystems = [ "exfat" "zfs" ];
    swraid.enable = false;
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
    hostName = "server";
    hostId = "13413401";
    useDHCP = true;
    firewall = {
      allowedTCPPorts = [ 80 443 ];
    };
  };

  time = { timeZone = "Europe/Berlin"; };

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
      path = ../../users/secrets.yaml;
    };
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
}

