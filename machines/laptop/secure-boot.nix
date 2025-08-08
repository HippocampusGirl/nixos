{ pkgs, ... }: {
  boot = {
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
    loader.efi.canTouchEfiVariables = true;
    loader.systemd-boot.enable = false;
  };
  environment.systemPackages = with pkgs; [ 
    # For debugging and troubleshooting Secure Boot
    sbctl
  ];
}
