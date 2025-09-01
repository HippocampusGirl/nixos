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
    brave
    freecad-wayland
    remmina
    pkgs.unstable.signal-desktop
    spotify
    vuescan
    zotero
  ];

  # Enable sound
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.printing = {
    enable = true;
    drivers = [ pkgs.brlaser pkgs.cups-brother-dcpl3550cdw ];
  };

  # Scanner
  hardware.sane.enable = true;
  services.udev.packages = with pkgs; [ vuescan ];

  environment.persistence."/persist".directories = [
    "/etc/NetworkManager/system-connections"
  ];
}
