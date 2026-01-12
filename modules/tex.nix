{ pkgs, ... }:
let
  tex = (pkgs.texlive.combine { inherit (pkgs.texlive) scheme-full biblatex-software; });
in
{
  environment.systemPackages = with pkgs;
    [ tex tex-fmt ];
  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [ corefonts vista-fonts ];
  };
}
