# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }: {
  imports = [
    ./fhs.nix
    ./kernel.nix
    ./vscode.nix
    ./wsl.nix
    ./zrepl.nix
    ../users/lea.nix
  ];

  environment = {
    systemPackages = with pkgs; [
      datalad
      git
      gnupg
      htop
      killall
      lsyncd
      micromamba
      nixfmt
      pre-commit
      python311
      tmux
      unzip
      vim
      wget
      zsh
    ];
  };

  fileSystems = {
    "/lea" = {
      device = "z/lea";
      fsType = "zfs";
    };
    "/scratch" = {
      device = "z/scratch";
      fsType = "zfs";
    };
    "/work" = {
      device = "z/work";
      fsType = "zfs";
    };
  };

  hardware = {
    opengl.enable = true;
    opengl.driSupport = true;
    opengl.driSupport32Bit = true;
  };

  i18n = { defaultLocale = "en_US.UTF-8"; };

  networking = {
    hostId = "1ea1eaaa";
    hostName = "laptop-nixos";
  };

  nix = {
    # Run garbage collection when disk is almost full
    extraOptions = ''
      min-free = ${toString (512 * 1024 * 1024)}
      experimental-features = nix-command flakes impure-derivations
    '';
    # Run garbage collection on a schedule
    gc = {
      automatic = true;
      dates = "Monday 01:00 UTC";
      options = "--delete-older-than 7d";
    };
    settings = { auto-optimise-store = true; };
  };

  programs = {
    command-not-found.enable = true;
    nix-ld.enable = true;
    zsh.enable = true;
  };

  system = {
    activationScripts = {
      wslMount = {
        text = ''
          /mnt/c/Windows/system32/schtasks.exe /run /tn "Mount physical disk to WSL"
        '';
        deps = [ ];
      };
    };
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

  time = { timeZone = "Europe/Berlin"; };

  virtualisation.docker = {
    autoPrune.enable = true;
    enableNvidia = true;
    extraOptions = "--storage-opt zfs.fsname=z/docker";
    storageDriver = "zfs";
  };
}
