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
      lsof
      lsyncd
      micromamba
      nixfmt
      nixos-generators
      nix-index
      pre-commit
      pv
      python311
      # ripgrep-all
      sops
      unzip
      wget
      zsh
    ];
  };
}