{ config, lib, pkgs, ... }:
let
  kernelVersion = "6.1.21.2";

  src = pkgs.fetchFromGitHub {
    owner = "microsoft";
    repo = "WSL2-Linux-Kernel";
    rev = "linux-msft-wsl-${kernelVersion}";
    sha256 = "sha256-szQ6swi0pFdwh3bF2HiVxbUnu/taw6yYWhBgyx7LFv4=";  # lib.fakeSha256
  };
  kernelConfig = pkgs.linuxKernel.manualConfig rec {
    inherit src;
    inherit (pkgs) lib;
    inherit (pkgs.linux_6_1) stdenv;

    version = "${kernelVersion}-microsoft-standard-WSL2";
    modDirVersion = version;
    configfile = pkgs.writeText "config" ''
    ${builtins.readFile "${src}/Microsoft/config-wsl"}
    CONFIG_DMIID=y
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
          sha256 = "sha256-eFRXZBXlYyK7/c2FaWwIOwXuzJ77J2GKXZoFeV4vbaE=";
        };
        patches = [];
      });
    });
in {
  boot = {
    inherit kernelPackages;
    modprobeConfig.enable = lib.mkForce true;
    supportedFilesystems = [ "zfs" ];
  };
  system = {
    build = with kernelPackages; { inherit kernel; };
    modulesTree = with kernelPackages; [ kernel zfs ];
    systemBuilderCommands = ''
      ln -s ${config.system.modulesTree} $out/kernel-modules
    '';
  };
}