{ pkgs, ... }: {
  environment = {
    systemPackages = with pkgs; [
      cached-nix-shell
      datalad
      dig
      gnupg
      home-manager
      jq
      killall
      lsof
      lsyncd
      micromamba
      nixfmt
      nixos-generators
      nix-index
      pre-commit
      python311
      # ripgrep-all
      unzip
      wget
      zsh
    ];
  };
}