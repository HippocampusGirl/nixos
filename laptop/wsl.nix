{ config, lib, pkgs, ... }: {
  wsl = {
    enable = true;

    wslConf = {
        automount = {
            enabled = true;
            mountFsTab = false;
            root = "/mnt";
        };
    };
    startMenuLaunchers = false;

    nativeSystemd = true;

    defaultUser = "lea";

    docker-native.enable = true;
  };
}