{ pkgs, ... }: {
  environment = {
    systemPackages = with pkgs;
      [
        (buildFHSEnv {
          name = "fhs";
          targetPkgs = _: [
            linux-pam
            libGL
            libxcrypt
            libxcrypt-legacy
            ncurses5
            openssl
            tcsh
            xorg.libXxf86vm
            which
            zlib
          ];
          runScript = "zsh";
        })
      ];
  };
}
