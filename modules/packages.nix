{ pkgs, ... }: {
  environment = {
    systemPackages = with pkgs; [
      cached-nix-shell
      cachix
      cmake
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
      nil
      nixfmt
      nixos-generators
      nix-index
      nix-tree
      openssl
      pciutils
      pkg-config
      pre-commit
      pv
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
