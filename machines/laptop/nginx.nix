{ pkgs, ... }: {
  services.nginx = {
    enable = true;
    additionalModules = with pkgs.nginxModules; [ dav ];

    virtualHosts = {
      "localhost" = {
        listenAddresses = [ "127.0.0.1" "[::1]" ];
        locations."/dav" = {
          root = "/work";
          basicAuth = { lea = "password"; };

          extraConfig = ''
            autoindex on;

            dav_methods PUT DELETE MKCOL COPY MOVE;
            dav_ext_methods PROPFIND OPTIONS;
            dav_access user:rw group:rw all:r;

            client_body_temp_path /var/cache/nginx;

            create_full_put_path on;
          '';
        };
      };
    };
    enableReload = true;
  };
  systemd.services.nginx.serviceConfig.ReadWritePaths = [ "/work/dav" ];
}
