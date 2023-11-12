{
  boot = {
    inherit kernelPackages;
    supportedFilesystems = [ "exfat" "zfs" ];
  };
}
