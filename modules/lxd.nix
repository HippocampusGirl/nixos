{ pkgs, ... }: {
  # LXD and nftables don't work together on NixOS currently, so we need 
  # rto use a workaround from
  # https://github.com/NixOS/nixpkgs/issues/163565#issuecomment-1065173100
  networking.firewall.trustedInterfaces = [ "lxdbr0" ];
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
      zfsSupport = true;
    };
  };
}
