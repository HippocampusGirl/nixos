{ pkgs, ... }: {
  boot = {
    supportedFilesystems = [ "exfat" "zfs" ];
    zfs = {
      package = pkgs.zfs_unstable;
    };
  };
  services.zfs = {
    autoScrub.enable = true;
    expandOnBoot = "all";
    trim.enable = true;
  };
}
