# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }: {
  imports = [ ./kernel.nix ./wsl.nix ./zrepl.nix ../users/lea.nix ];

  environment = {
    systemPackages = with pkgs; [ git gnupg htop nixfmt tmux vim wget zsh ];
  };

  i18n = { defaultLocale = "en_US.UTF-8"; };

  networking = {
    hostId = "1ea1eaaa";
    hostName = "laptop-nixos";
  };

  nix = {
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
    command-not-found.enable = true;
    nix-ld.dev.enable = true;
    zsh.enable = true;
  };

  services = {
    # Automatically fix vscode server executable
    vscode-server = {
      enable = true;
      installPath = "~/.vscode-server-insiders";
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

  time = { timeZone = "Europe/Berlin"; };
}
