{ pkgs, config, ... }: {
  environment = {
    shellAliases = {
      gnome-open = "wslview";
      kde-open = "wslview";
      xdg-open = "wslview";
    };
    systemPackages = with pkgs; [
      wslu
    ] ++ config.hardware.graphics.extraPackages;
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

    useWindowsDriver = true; # CUDA support

    wslConf = {
      automount = {
        enabled = true;
        mountFsTab = false;
        root = "/mnt";
      };
      network = { generateResolvConf = false; };
    };
  };

  # https://github.com/nix-community/NixOS-WSL/issues/578#issuecomment-2459445182
  programs.nix-ld.libraries = config.hardware.graphics.extraPackages;
}
