{ config, pkgs, ... }: {
  services = {
    # Automatically fix vscode server executable
    vscode-server = {
      enable = true;
      installPath = "~/.vscode-server-insiders";
    };
  };
  
  wsl = {
    # Needed to enable WSL wrapper for running VSCode WSL
    binShPkg = lib.mkForce (with pkgs; runCommand "nixos-wsl-bash-wrapper"
      {
        nativeBuildInputs = [ makeWrapper ];
      } 
      ''makeWrapper ${bashInteractive}/bin/sh $out/bin/sh \
        --prefix PATH ':' ${lib.makeBinPath ([ systemd gnugrep coreutils findutils gnutar gzip git ])}
        --prefix A:B
      ''
    );
  };
}