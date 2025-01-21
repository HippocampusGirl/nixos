{ config, pkgs, ... }: {
  services.postgresql = {
    enable = true;
    enableJIT = true;
    enableTCPIP = false;

    package = pkgs.postgresql_17_jit;

    dataDir = "/postgres/${config.services.postgresql.package.psqlSchema}";

    settings = {
      # Disable for ZFS
      full_page_writes = false;
    };
  };
  # systemd.services.postgresql.postStart = lib.mkForce '''';
}
