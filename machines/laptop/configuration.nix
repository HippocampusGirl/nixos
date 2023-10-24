# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }: {
  imports = [
    ./kernel.nix
    ./vscode.nix
    ./wsl.nix
    ./zrepl.nix
  ];

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

  networking = {
    hostId = "13413404";
    hostName = "laptop-nixos";
  };

  nixpkgs.config.allowUnfree = true;

  sops = {
    defaultSopsFile = ../../secrets.yaml;
    # If either of these paths does not exist immediately after boot, then 
    # sops-nix will fail and not decrypt any secrets. That means that the
    # the secrets will not be available when the users are generated. 
    # This can lead to login issues
    age.sshKeyPaths = [ "/mnt/c/Users/Lea/WSL/ssh_host_ed25519_key" ];
    gnupg.sshKeyPaths = [ "/mnt/c/Users/Lea/WSL/ssh_host_rsa_key" ];
    # Specification of the secrets/
    secrets."users/root/hashed-password" = { neededForUsers = true; };
    secrets."users/lea/hashed-password" = { neededForUsers = true; };
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
