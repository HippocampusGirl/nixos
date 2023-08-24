{ config, lib, pkgs, ... }: {
  wsl = {
    enable = true;

    # Needed to enable WSL wrapper for running VSCode WSL
    binShPkg = lib.mkForce (with pkgs; runCommand "nixos-wsl-bash-wrapper"
      {
        nativeBuildInputs = [ makeWrapper ];
      } 
      ''makeWrapper ${bashInteractive}/bin/sh $out/bin/sh \
        --prefix PATH ':' ${lib.makeBinPath ([ systemd gnugrep coreutils findutils gnutar gzip git ])}
      ''
    );

    wslConf = {
        automount = {
            enabled = true;
            mountFsTab = false;
            root = "/mnt";
        };
    };
    startMenuLaunchers = false;

    nativeSystemd = true;

    defaultUser = "lea";

    docker-native.enable = true;
  };
}