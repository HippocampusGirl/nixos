{ pkgs, ... }:
let
  mta-sts-web = {
    forceSSL = true;
    enableACME = true;
    locations."=/.well-known/mta-sts.txt".alias =
      pkgs.writeText "mta-sts.txt" ''
        version: STSv1
        mode: testing
        mx: aspmx.l.google.com
        mx: alt3.aspmx.l.google.com
        mx: alt4.aspmx.l.google.com
        mx: alt1.aspmx.l.google.com
        mx: alt2.aspmx.l.google.com
        max_age: 604800
      '';
  };
in {
  services.nginx.virtualHosts = {
    "mta-sts.lea.science" = mta-sts-web;
    "mta-sts.fmri.science" = mta-sts-web;
    "mta-sts.lw.is" = mta-sts-web;
  };
}
