{ config, pkgs, ... }:
let
  gp-saml-gui = pkgs.gp-saml-gui.overrideAttrs (_: {
    patches = [
      ./gp-saml-gui.patch
    ];
  });
in
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
    secrets."charite/openvpn/secrets" = { owner = "lea"; sopsFile = ./secrets.yaml; };
  };
  systemd.user.services.openvpn-charite-management = {
    enable = true;
    startLimitIntervalSec = 0;

    wantedBy = [ "graphical-session.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = let python = pkgs.python3.withPackages (ps: with ps; [ tkinter ]); in ''
        ${python}/bin/python ${./openvpn_management.py}  \
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
  systemd.user.services.globalprotect-ini-usc =
    let
      portal = "vpn.ini.usc.edu";
    in
    {
      description = "GlobalProtect/OpenConnect instance '${portal}'";

      enable = true;
      wantedBy = [ "graphical-session.target" ];
      after = [ "network.target" ];
      restartTriggers = [ config.environment.etc."vpnc/post-connect.d/update-systemd-resolved".source ];

      path = [ gp-saml-gui pkgs.openconnect pkgs.sudo ];

      serviceConfig = {
        Type = "simple";
        ExecStart = ''
          ${gp-saml-gui}/bin/gp-saml-gui --allow-insecure-crypto --pkexec-openconnect --gateway ${portal}
        '';
        RemainAfterExit = true;
      };
    };
}
