{ config, pkgs, ... }:
{
  services = {
    openvpn.servers."charite" =
      let
        update-systemd-resolved = ''
          ${pkgs.update-systemd-resolved}/libexec/openvpn/update-systemd-resolved
          resolvectl dnsovertls $dev no
          resolvectl domain $dev charite.de bihealth.org'';
      in
      {
        config = ''
          config ${config.sops.secrets."charite/openvpn/config".path}
          management /run/openvpn-charite-management.sock unix
          management-query-passwords
        '';
        up = update-systemd-resolved;
        down = update-systemd-resolved;
      };

  };
  sops = {
    secrets."charite/openvpn/config" = { sopsFile = ./secrets.yaml; };
    secrets."charite/openvpn/secrets" = { sopsFile = ./secrets.yaml; };
    secrets."charite/openvpn/management-script" = { sopsFile = ./secrets.yaml; mode = "0500"; };
  };
  systemd.services.openvpn-charite-management = {
    enable = true;
    startLimitIntervalSec = 0;

    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = ''
        ${pkgs.python3}/bin/python ${config.sops.secrets."charite/openvpn/management-script".path} \
          ${config.sops.secrets."charite/openvpn/secrets".path}
      '';
      Restart = "always";
      RestartSec = "1s";
    };
  };
  environment.etc."vpnc/post-connect.d/update-systemd-resolved" = {
    source = ''${pkgs.writeShellScriptBin "update-systemd-resolved" ''
      resolvectl dnsovertls $TUNDEV no ;
    ''}/bin/update-systemd-resolved'';
    mode = "0755";
  };
  systemd.services.globalprotect-ini-usc =
    let
      portal = "vpn.ini.usc.edu";
    in
    {
      description = "GlobalProtect/OpenConnect instance '${portal}'";

      enable = false;
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      restartTriggers = [ config.environment.etc."vpnc/post-connect.d/update-systemd-resolved".source ];

      path = [ pkgs.openconnect pkgs.gp-saml-gui pkgs.sudo ];

      serviceConfig = {
        Type = "simple";
        Environment = "DISPLAY=:0";
        ExecStart = "${pkgs.gp-saml-gui}/bin/gp-saml-gui --gateway ${portal} --sudo-openconnect";
        RemainAfterExit = true;
      };
    };
}



