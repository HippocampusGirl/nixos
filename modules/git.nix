{ pkgs, ... }: {
  programs.git.enable = true;
  environment = { systemPackages = with pkgs; [ git-annex ]; };
}
