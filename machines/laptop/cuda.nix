{ pkgs, lib, ... }: {
  environment = {
    systemPackages = with pkgs.cudaPackages; [ cudatoolkit cudnn ];
  };
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    setLdLibraryPath = true;
  };
  programs.nix-ld.libraries = with pkgs;
    (lib.mkOptionDefault [ cudaPackages.cudatoolkit cudaPackages.cudnn ]);
}
