{ pkgs, ... }: {
  virtualisation = {
    containers.enable = true;
    docker = {
      enable = true;
      enableOnBoot = false;
      autoPrune.enable = true;
      daemon.settings = {
        default-address-pools = [
          { base = "172.27.0.0/16"; size = 24; }
        ];
      };
      extraOptions = "--storage-opt zfs.fsname=z/docker";
      extraPackages = with pkgs; [ iptables ];
      storageDriver = "zfs";
    };
  };
}
