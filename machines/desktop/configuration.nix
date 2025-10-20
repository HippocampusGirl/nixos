# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ pkgs, lib, ... }: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot = {
    # Use the systemd-boot EFI boot loader
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    # # Use hardware sensors
    # kernelModules = [ "nct6775" ];
    supportedFilesystems = [ "exfat" "zfs" ];
    zfs = {
      devNodes = "/dev/disk/by-path";
      requestEncryptionCredentials = true;
    };
  };

  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;
  hardware.nvidia-container-toolkit.enable = true;
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "cuda_cccl"
    "cuda_cudart"
    "cuda_cuobjdump"
    "cuda_cupti"
    "cuda_cuxxfilt"
    "cuda_gdb"
    "cuda-merged"
    "cuda_nvcc"
    "cuda_nvdisasm"
    "cuda_nvml_dev"
    "cuda_nvprune"
    "cuda_nvrtc"
    "cuda_nvtx"
    "cuda_profiler_api"
    "cuda_sanitizer_api"
    "cudnn"
    "libcublas"
    "libcufft"
    "libcurand"
    "libcusolver"
    "libcusparse"
    "libnpp"
    "libnvjitlink"
    "nvidia-settings"
    "nvidia-x11"
    "tensorrt"
  ];
  boot.kernelModules = [
    "nvidia_uvm"
  ];
  environment.systemPackages = with pkgs; [
    ffmpeg-full
    cudatoolkit
    stdenv.cc
  ];
  environment.sessionVariables = {
    CPATH = with pkgs; [
      "${cudatoolkit}/include"
      "${cudaPackages.cudnn}/include"
    ];
    LD_LIBRARY_PATH = [ "/run/opengl-driver/lib" ];
  };
  programs.nix-ld.libraries = with pkgs; [ cudatoolkit cudaPackages.cudnn ];

  documentation = {
    # Disable documentation to improve performance
    enable = false;
    nixos.enable = false;
  };

  networking = {
    hostName = "desktop";
    hostId = "13413404";
    useDHCP = true;
  };

  time = { timeZone = "Europe/Berlin"; };

  sops = {
    defaultSopsFile = ./secrets.yaml;
    # If either of these paths does not exist immediately after boot, then 
    # sops-nix will fail and not decrypt any secrets. That means that the
    # the secrets will not be available when the users are generated. 
    # This can lead to login issues
    age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
    # Specification of the secrets/
    secrets."users/lea/hashed-password" = { neededForUsers = true; };
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}
