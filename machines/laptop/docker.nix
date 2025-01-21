{
  virtualisation = {
    containers.enable = true;
    docker = {
      autoPrune.enable = true;
      enable = true;
      extraOptions = "--storage-opt zfs.fsname=z/docker --iptables=False";
      storageDriver = "zfs";
    };
  };
}
