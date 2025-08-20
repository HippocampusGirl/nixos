{ pkgs, ... }: {
  boot = {
    supportedFilesystems = [ "exfat" "zfs" ];
    zfs.package = pkgs.unstable.zfs_unstable;
  };
  services.zfs = {
    autoScrub.enable = true;
    expandOnBoot = "all";
    trim.enable = true;
  };
}
