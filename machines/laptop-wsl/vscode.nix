{
  services = {
    # Automatically fix vscode server executable
    vscode-server = {
      enable = true;
      installPath = [
        "$HOME/.vscode-server"
        "$HOME/.vscode-server-insiders"
      ];
    };
  };
}
