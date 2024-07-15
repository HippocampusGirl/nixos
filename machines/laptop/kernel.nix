{ config, lib, pkgs, ... }:
let
  kernelVersion = "6.6.36.3";
  baseKernel = pkgs.linux_6_6;

  src = pkgs.fetchFromGitHub {
    owner = "microsoft";
    repo = "WSL2-Linux-Kernel";
    rev = "linux-msft-wsl-${kernelVersion}";
    sha256 = "sha256-kNNEJ81rlM0ns+bdiiSpYcM2hZUFjXb7EgGgHEI7b04=";
  };

  # Adapted from https://github.com/meatcar/wsl2-kernel-nix
  kernelConfig = pkgs.linuxKernel.manualConfig rec {
    inherit src;
    inherit (pkgs) lib;
    inherit (baseKernel) stdenv;

    version = "${kernelVersion}-microsoft-standard-WSL2";
    modDirVersion = version;
    configfile = pkgs.writeText "config" ''
      ${builtins.readFile "${src}/Microsoft/config-wsl"}
    '';

    allowImportFromDerivation = true;
  };

  baseKernelPackages = pkgs.linuxPackagesFor kernelConfig;
  kernelPackages = baseKernelPackages.extend (self: super: {
    kernel = super.kernel.overrideAttrs (old: {
      passthru = old.passthru // { inherit (baseKernel) features; };
    });
  });

  # Adapted from nixpkgs/nixos/modules/system/boot/kernel.nix
  # which is not run because NixOS for WSL sets 
  # config.boot.kernel.enable to false
  kernelModulesConf = pkgs.writeText "nixos.conf" ''
    ${lib.concatStringsSep "\n" config.boot.kernelModules}
  '';
in
{
  boot = {
    inherit kernelPackages;
    modprobeConfig.enable = lib.mkForce true;
    supportedFilesystems = [ "exfat" "zfs" ];
  };
  # Create /etc/modules-load.d/nixos.conf, which is read by
  # systemd-modules-load.service to load required kernel modules.
  environment.etc = { "modules-load.d/nixos.conf".source = kernelModulesConf; };
  system = {
    activationScripts = {
      # Copy the kernel to where it is expected by the WSL configuration
      copyKernel =
        let
          kernelBuildPath = "${config.boot.kernelPackages.kernel}/"
            + "${pkgs.stdenv.hostPlatform.linux-kernel.target}";
          kernelTargetPath = "/mnt/c/Users/Lea/WSL/"
            + "${pkgs.stdenv.hostPlatform.linux-kernel.target}";
        in
        ''
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
