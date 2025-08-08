{ pkgs, ... }: {
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [ libGL linux-pam xorg.libXxf86vm ];
  };
}
