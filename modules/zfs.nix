{ lib, config, pkgs, ... }:
let
  # The "z" pool was created with a development version of openzfs
  # so we are stuck on that until 2.2.0 is released to nixpkgs
  zfsVersion = "2.2.0";
  kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages.extend (self: super: {
    zfs = super.zfs.overrideAttrs (old: {
      name = "zfs-kernel-${zfsVersion}-${super.kernel.version}";
      src = pkgs.fetchFromGitHub {
        owner = "openzfs";
        repo = "zfs";
        rev = "zfs-${zfsVersion}";
        sha256 = "sha256-s1sdXSrLu6uSOmjprbUa4cFsE2Vj7JX5i75e4vRnlvg=";
      };
      patches = [ ];
    });
  });
in {
  boot = {
    inherit kernelPackages;
    supportedFilesystems = [ "exfat" "zfs" ];
  };
}