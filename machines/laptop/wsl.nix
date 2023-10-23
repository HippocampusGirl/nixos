{ config, lib, pkgs, ... }: {
  wsl = {
    enable = true;

    wslConf = {
      automount = {
        enabled = true;
        mountFsTab = false;
        root = "/mnt";
      };
      # boot = {
      #   command = ''
      #     /mnt/c/Windows/system32/schtasks.exe /run /tn "Mount physical disk to WSL"'';
      # };
    };
    startMenuLaunchers = false;
    nativeSystemd = true;
    defaultUser = "lea";
    docker-native.enable = true;
  };
}
