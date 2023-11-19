{ pkgs, lib, ... }:

let
  cloudflareIPs = pkgs.fetchurl {
    url = "https://www.cloudflare.com/ips-v4";
    hash = "sha256-8Cxtg7wBqwroV3Fg4DbXAMdFU1m84FTfiE5dfZ5Onns=";
  };
  setRealIpFromConfig = lib.concatMapStrings (ip: ''
    set_real_ip_from ${ip};
  '') (lib.strings.splitString "\n" (builtins.readFile "${cloudflareIPs}"));
in {
  services.nginx = {
    enable = true;
    appendHttpConfig = ''
      ${setRealIpFromConfig}
      real_ip_header CF-Connecting-IP;
    '';
  };
}
