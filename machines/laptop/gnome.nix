{ pkgs, ... }: {
  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

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
  programs.ydotool.enable = true;
  programs.zoom-us = {
    enable = true;
    # package = pkgs.unstable.zoom-us;
  };
  environment.systemPackages =
    let
      ydotool-paste = pkgs.writeShellApplication
        {
          name = "ydotool-paste";
          runtimeInputs = with pkgs; [ ydotool wl-clipboard ];
          text = "wl-paste --no-newline | ydotool type --file=-";
        };
    in
    with pkgs; [
      alacritty
      ausweisapp
      brave
      discord
      freecad-wayland
      gnome-boxes # VM management
      gnomeExtensions.appindicator
      hunspellDicts.de-de
      hunspellDicts.en-us
      hyphenDicts.de-de
      hyphenDicts.en-us
      inkscape
      krita
      libreoffice
      masterpdfeditor4
      remmina
      shfmt
      pkgs.unstable.signal-desktop
      pkgs.unstable.spotify
      pkgs.unstable.vscode
      vuescan
      swtpm
      vlc
      ydotool-paste
      zotero
    ];
  programs.obs-studio = {
    enable = true;

    package = (
      pkgs.obs-studio.override {
        cudaSupport = true;
      }
    );

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-vaapi
      obs-gstreamer
      obs-vkcapture
      obs-source-record
    ];
  };

  # Enable sound
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.printing = {
    enable = true;
    drivers = [ pkgs.brlaser pkgs.hplipWithPlugin ];
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
