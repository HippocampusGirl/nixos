{ pkgs, ... }: {
  environment = {
    systemPackages = with pkgs;
      [
        (buildFHSEnv {
          name = "fhs";
          targetPkgs = _: [ linux-pam libGL micromamba xorg.libXxf86vm which zlib ];
          runScript = "zsh";
        })
      ];
  };
}
