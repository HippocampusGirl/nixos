# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }: {
  imports = [ ./kernel.nix ./wsl.nix ../users/lea.nix ];

  environment = {
    systemPackages = with pkgs; [
      git
      htop
      nixfmt
      nodejs
      # ripgrep-all
      vim
      wget
      zsh
    ];
  };

  networking = {
    hostId = "1ea1eaaa";
    hostName = "laptop-nixos";
  };

  nix = {
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

  services = {
    vscode-server = {
      enable = true;
      installPath = "~/.vscode-server-insiders";
    };
  };

  system = { stateVersion = "23.05"; };
}
