{ pkgs, ... }: {
  environment = {
    systemPackages = with pkgs; [
      cached-nix-shell
      datalad
      dig
      gnupg
      home-manager
      iftop
      jq
      killall
      lm_sensors
      lsof
      lsyncd
      micromamba
      nixfmt
      nixos-generators
      nix-index
      openssl
      pciutils
      pre-commit
      pv
      regclient
      ripgrep-all
      sops
      usbutils
      unzip
      wget
      zsh
    ];
  };
}