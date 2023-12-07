{ config, pkgs, ... }: {
  services.postgresql = {
    enable = true;
    enableJIT = true;
    enableTCPIP = false;

    package = pkgs.postgresql_16_jit;

    dataDir = "/postgres/${config.services.postgresql.package.psqlSchema}";

    settings = {
      # Disable for ZFS
      full_page_writes = false;
    };
  };
}
