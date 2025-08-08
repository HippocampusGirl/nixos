{ pkgs, ... }: {
  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  environment.gnome.excludePackages = with pkgs; [
    epiphany
    gedit
    totem
    yelp
    geary
    gnome-calendar
    gnome-contacts
    gnome-maps
    gnome-music
    gnome-photos
    gnome-tour
    evince
  ];

  programs.firefox = {
    enable = true;
    package = pkgs.unstable.firefox;
  };
  programs.zoom-us.enable = true;
  environment.systemPackages = with pkgs; [
    alacritty
    remmina
    zotero
  ];

  # Enable sound
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
}
