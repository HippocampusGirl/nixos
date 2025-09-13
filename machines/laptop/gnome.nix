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
    gnome-boxes # VM management
    gnomeExtensions.appindicator
    libreoffice
    remmina
    pkgs.unstable.signal-desktop
    pkgs.unstable.spotify
    vuescan
    swtpm
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
  services.udev.packages = with pkgs; [ vuescan gnome-settings-daemon ];

  environment.persistence."/persist".directories = [
    "/etc/NetworkManager/system-connections"
  ];

  services.xserver.xkb.extraLayouts.ultimatekeys =
    let
      source = pkgs.fetchFromGitHub {
        owner = "pieter-degroote";
        repo = "UltimateKEYS";
        rev = "r2025-08-14";
        sha256 = "sha256-SgFqcHsy0mz+T7/XT26zRLXBF8CgreKzQu1P1bc6oWA=";
      };
    in
    {
      description = "UltimateKEYS";
      languages = [
        "deu"
        "eng"
      ];
      symbolsFile = "${source}/linux-xkb/custom";
    };
}
