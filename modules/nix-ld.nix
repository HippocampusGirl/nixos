{ pkgs, ... }: {
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [ libGL xorg.libXxf86vm ];
  };
}
