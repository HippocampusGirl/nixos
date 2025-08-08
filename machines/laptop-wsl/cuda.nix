{ pkgs, lib, ... }: {
  environment = {
    systemPackages = with pkgs.cudaPackages; [ cudatoolkit cudnn ];
  };
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  programs.nix-ld.libraries = with pkgs;
    (lib.mkOptionDefault [ cudaPackages.cudatoolkit cudaPackages.cudnn ]);
}
