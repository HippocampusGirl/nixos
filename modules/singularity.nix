{ pkgs, ... }: {
  programs.singularity = {
    enable = true;
    enableFakeroot = true;
    enableSuid = true;
    package = pkgs.apptainer;
  };
}
