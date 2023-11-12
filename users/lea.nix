{ config, pkgs, ... }: {
  users.extraUsers.lea = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets."users/lea/hashed-password".path;
    
    uid = 1000;
    extraGroups = [
      "docker"  # Enable docker
      "wheel" # Enable sudo
    ];

    home = "/lea";
    createHome = true;

    shell = pkgs.zsh;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIETA8z05h0cx/Zma9WRKNcG+ckBJ1k35dGYLnAew1BXZ"
    ];

    subUidRanges = [{
      startUid = 1000000;
      count = 1000000;
    }];
    subGidRanges = [{
      startGid = 1000000;
      count = 1000000;
    }];
  };
}
