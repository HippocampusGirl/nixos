{
  virtualisation = {
    lxc = {
      enable = true;
      lxcfs = { enable = true; };
    };
    lxd = {
      enable = true;
      # This turns on a few sysctl settings that the LXD documentation recommends
      # for running in production.
      recommendedSysctlSettings = true;
    };
  };
}
