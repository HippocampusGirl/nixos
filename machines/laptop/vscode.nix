{ config, pkgs, lib, ... }: {
  services = {
    # Automatically fix vscode server executable
    vscode-server = {
      enable = true;
      installPath = "~/.vscode-server-insiders";
    };
  };
}
