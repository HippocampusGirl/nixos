{ pkgs, ... }: {
  boot = {
    lanzaboote = {
      enable = true;

      configurationLimit = 1;
      pkiBundle = "/etc/secureboot";

      settings = {
        reboot-for-bitlocker = true;
      };
    };
    loader.systemd-boot.enable = false;
  };
  environment.systemPackages = with pkgs; [ sbctl ];
  environment.persistence."/persist".directories = [ "/etc/secureboot" ];
}
