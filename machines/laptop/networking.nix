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
          auth-user-pass ${config.sops.secrets."charite/openvpn/credentials".path}
        '';
        up = update-systemd-resolved;
        down = update-systemd-resolved;
      };

  };
  sops = {
    secrets."charite/openvpn/config" = { sopsFile = ./secrets.yaml; };
    secrets."charite/openvpn/credentials" = { sopsFile = ./secrets.yaml; };
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

      enable = true;
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



