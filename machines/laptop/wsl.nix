{ config, lib, pkgs, ... }: {
  wsl = {
    enable = true;

    # Patches for vscode server
    extraBin = with pkgs; [
      { src = "${coreutils}/bin/uname"; }
      { src = "${coreutils}/bin/dirname"; }
      { src = "${coreutils}/bin/readlink"; }
      { src = "${coreutils}/bin/cat"; }
      { src = "${gnused}/bin/sed"; }
    ];

    startMenuLaunchers = false;
    nativeSystemd = true;
    defaultUser = "lea";
    usbip.enable = true;
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
  };
}
