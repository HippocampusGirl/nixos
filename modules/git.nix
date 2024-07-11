{ pkgs, ... }: {
  programs.git = { enable = true; lfs.enable = true; prompt.enable = true; };
  environment = { systemPackages = with pkgs; [ git-annex ]; };
}
