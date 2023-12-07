{
  boot = { supportedFilesystems = [ "exfat" "zfs" ]; };
  services.zfs = {
    autoScrub.enable = true;
    expandOnBoot = "all";
    trim.enable = true;
  };
}
