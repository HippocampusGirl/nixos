{ config, lib, pkgs, ... }:
let
  kernelVersion = "6.1.21.2";

  src = pkgs.fetchFromGitHub {
    owner = "microsoft";
    repo = "WSL2-Linux-Kernel";
    rev = "linux-msft-wsl-${kernelVersion}";
    sha256 = "sha256-szQ6swi0pFdwh3bF2HiVxbUnu/taw6yYWhBgyx7LFv4=";
  };

  # Adapted from https://github.com/meatcar/wsl2-kernel-nix
  kernelConfig = pkgs.linuxKernel.manualConfig rec {
    inherit src;
    inherit (pkgs) lib;
    inherit (pkgs.linux_6_1) stdenv;

    version = "${kernelVersion}-microsoft-standard-WSL2";
    modDirVersion = version;
    configfile = pkgs.writeText "config" ''
      ${builtins.readFile "${src}/Microsoft/config-wsl"}
    '';

    allowImportFromDerivation = true;
  };

  # The "z" pool was created with a development version of openzfs
  # so we are stuck on that until 2.2.0 is released
  zfsVersion = "2.2.0-rc3";
  baseKernelPackages = pkgs.linuxPackagesFor kernelConfig;
  kernel = baseKernelPackages.kernel;
  kernelPackages = baseKernelPackages.extend (self: super: {
    zfs = super.zfs.overrideAttrs (old: {
      name = "zfs-kernel-${zfsVersion}-${kernel.version}";
      src = pkgs.fetchFromGitHub {
        owner = "openzfs";
        repo = "zfs";
        rev = "zfs-${zfsVersion}";
        sha256 = "sha256-7Kql1lbDxrrKXG9XjeDQAShpY5RUYHVTiMATzGNHvfo=";
      };
      patches = [ ];
    });
  });

  # Adapted from nixpkgs/nixos/modules/system/boot/kernel.nix
  # which is not run because NixOS for WSL sets 
  # config.boot.kernel.enable to false
  kernelModulesConf = pkgs.writeText "nixos.conf" ''
    ${lib.concatStringsSep "\n" config.boot.kernelModules}
  '';
in {
  boot = {
    inherit kernelPackages;
    modprobeConfig.enable = lib.mkForce true;
    supportedFilesystems = [ "zfs" ];
  };
  # Create /etc/modules-load.d/nixos.conf, which is read by
  # systemd-modules-load.service to load required kernel modules.
  environment.etc = { "modules-load.d/nixos.conf".source = kernelModulesConf; };
  system = {
    activationScripts = {
      # Copy the kernel to where it is expected by the WSL configuration
      copyKernel = let
        kernelBuildPath = "${config.boot.kernelPackages.kernel}/"
          + "${pkgs.stdenv.hostPlatform.linux-kernel.target}";
        kernelTargetPath = "/mnt/c/Users/Lea/WSL/"
          + "${pkgs.stdenv.hostPlatform.linux-kernel.target}";
      in ''
        mv -v -f ${kernelTargetPath} ${kernelTargetPath}1
        cp -v ${kernelBuildPath} ${kernelTargetPath}
      '';
    };
    build = with kernelPackages; { inherit kernel; };
    modulesTree = with kernelPackages; [ kernel zfs ];
    systemBuilderCommands = ''
      ln -s ${config.system.modulesTree} $out/kernel-modules
    '';
  };
}
