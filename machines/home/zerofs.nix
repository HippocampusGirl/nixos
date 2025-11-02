{ config, ... }: {
  imports = [ ../../packages/zerofs.nix ];
  services.zerofs = {
    enable = true;
    settings = {
      cache = {
        dir = "/var/cache/zerofs";
        disk_size_gb = 10.0;
        memory_size_gb = 2.0;
      };
      storage = {
        url = "\${ZEROFS_URL}";
        encryption_password = "\${ZEROFS_PASSWORD}";
      };
      aws = {
        access_key_id = "\${AWS_ACCESS_KEY_ID}";
        secret_access_key = "\${AWS_SECRET_ACCESS_KEY}";
        endpoint = "\${AWS_ENDPOINT_URL}";
        allow_http = "false";
      };
      servers.ninep = {
        addresses = [ "127.0.0.1:5564" ];
      };
      servers.nbd = {
        addresses = [ "127.0.0.1:10809" ];
      };
    };
    environmentFile = config.sops.secrets."zerofs/env".path;
  };
  programs.nbd.enable = true;

  sops = {
    secrets."zerofs/env" = {
      mode = "0440";
      owner = config.users.users.zerofs.name;
      group = config.users.users.zerofs.group;
    };
  };
}
