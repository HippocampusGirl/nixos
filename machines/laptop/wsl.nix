{ pkgs, ... }: {
  environment = {
    shellAliases = {
      gnome-open = "wslview";
      kde-open = "wslview";
      xdg-open = "wslview";
    };
    systemPackages = with pkgs; [
      wslu
    ];
  };
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
    };
  };
}
