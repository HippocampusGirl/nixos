{
  # wsl.docker-desktop.enable = true;
  virtualisation.docker = {
    autoPrune.enable = true;
    enable = true;
    enableNvidia = true;
    extraOptions = "--storage-opt zfs.fsname=z/docker --iptables=False";
    storageDriver = "zfs";
  };
}
