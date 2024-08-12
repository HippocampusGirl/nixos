{pkgs, ...}: {
  boot = {
    lanzaboote = {
      enable = true;

      configurationLimit = 1;
      pkiBundle = "/etc/secureboot";
    }; 
    loader.systemd-boot.enable = false;
  };
  environment.systemPackages = with pkgs; [ sbctl ];
  environment.persistence."/persist".directories = ["/etc/secureboot"];
}