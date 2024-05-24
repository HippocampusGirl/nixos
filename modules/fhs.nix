{ pkgs, ... }: {
  environment = {
    systemPackages = with pkgs;
      [
        (buildFHSUserEnv {
          name = "fhs";
          targetPkgs = _: [ libGL micromamba xorg.libXxf86vm which ];
          runScript = "zsh";
        })
      ];
  };
}
