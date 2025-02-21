{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    gnupg
  ];
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    settings = {
      default-cache-ttl = 2592000;
      max-cache-ttl = 2592000;
    };
  };
}
