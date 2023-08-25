{ config, pkgs, ... }:
let base = pkgs.appimageTools.defaultFhsEnvArgs;
in {
  environment = {
    systemPackages = with pkgs;
      [
        (buildFHSUserEnv (base // {
          name = "fhs";
          targetPkgs = pkgs: (base.targetPkgs pkgs) ++ [ micromamba pkg-config ];
          profile = ''
            set -e
            eval "$(micromamba shell hook -s zsh)"
            export MAMBA_ROOT_PREFIX="~/micromamba"
            set +e
          '';
          runScript = "zsh";
        }))
      ];
  };
}
