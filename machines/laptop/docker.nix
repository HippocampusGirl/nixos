{
  hardware.nvidia-container-toolkit.enable = true;
  virtualisation.docker = {
    autoPrune.enable = true;
    enable = true;
    extraOptions = "--storage-opt zfs.fsname=z/docker --iptables=False";
    storageDriver = "zfs";
  };
}
