{ pkgs, ... }: {
  environment = {
    systemPackages = with pkgs; [
      cached-nix-shell
      cachix
      datalad
      dig
      file
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
      nix-tree
      openssl
      pciutils
      pre-commit
      pv
      regclient
      ripgrep-all
      sops
      tree
      usbutils
      unzip
      wget
      zsh
    ];
  };
}
