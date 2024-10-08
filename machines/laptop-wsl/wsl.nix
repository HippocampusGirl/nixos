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
  systemd.managerEnvironment = {
    # Allow running zram-generator on wsl
    "ZRAM_GENERATOR_ROOT" = "/";
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

  # CUDA
  wsl.useWindowsDriver = true;

  # Networking 
  wsl.wslConf.network = { generateResolvConf = false; };
}
