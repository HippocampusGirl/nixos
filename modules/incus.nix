{
  networking.firewall.trustedInterfaces = [ "incusbr0" ];
  virtualisation = {
    lxc = {
      enable = true;
      lxcfs = { enable = true; };
    };
    incus = {
      enable = true;
      preseed = {
        networks = [
          {
            name = "incusbr0";
            type = "bridge";
            config = {
              "ipv4.address" = "auto";
              "ipv4.nat" = true;
              "ipv6.address" = "none";
            };
          }
        ];
        storage_pools = [
          {
            name = "default";
            driver = "zfs";
            config = {
              source = "z/incus";
              "volume.size" = "100GiB";
              "volume.zfs.block_mode" = true;
            };
          }
        ];
        profiles = [
          {
            name = "default";
            devices = {
              eth0 = {
                name = "eth0";
                network = "incusbr0";
                type = "nic";
              };
              root = {
                path = "/";
                pool = "default";
                type = "disk";
              };
            };
          }
        ];

      };
    };
  };
}
