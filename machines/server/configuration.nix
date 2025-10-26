# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, lib, config, ... }: {
  imports = [
    ./cloudflare.nix
    ./docker-registry.nix
    ./garm.nix
    # Include the results of the hardware scan
    ./hardware-configuration.nix
    ./mattermost.nix
    ./networking.nix
    ./nginx.nix
    ./optuna.nix
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
    kernelPackages = pkgs.unstable.linuxPackages_6_16;
    kernel.sysctl = {
      "vm.dirty_background_ratio " = 5;
      "vm.dirty_ratio" = 10;
    };
    supportedFilesystems = [ "exfat" "zfs" ];
    tmp.cleanOnBoot = true;
    zfs = {
      devNodes = "/dev/disk/by-path";
      requestEncryptionCredentials = true;
    };
  };
  # Fix for kernel 6.16 module structure changes
  system.modulesTree = [
    (lib.getOutput "modules" config.boot.kernelPackages.kernel)
  ];

  documentation = {
    # Disable documentation to improve performance
    enable = false;
    nixos.enable = false;
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;
    # If either of these paths does not exist immediately after boot, then 
    # sops-nix will fail and not decrypt any secrets. That means that the
    # the secrets will not be available when the users are generated. 
    # This can lead to login issues
    age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
  };

  system = {
    # Enable automatic security updates
    autoUpgrade = {
      enable = true;
      allowReboot = false;
      dates = "daily UTC";
      flags = [
        "--update-input"
        "nixpkgs"
        "--no-write-lock-file"
      ];
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

