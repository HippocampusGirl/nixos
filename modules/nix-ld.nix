{ pkgs, ... }: {
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      libGL
      libxcrypt
      libxcrypt-legacy
      linux-pam
      xorg.libXxf86vm
      ncurses5
    ];
  };
}
