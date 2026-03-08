{ pkgs, ... }: {
  hardware = {
    bluetooth.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm = {
    enable = true;
    autoSuspend = false;
  };
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
  programs.zoom-us.enable = true;
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
      gnome-network-displays
      gnomeExtensions.appindicator
      hunspellDicts.de-de
      hunspellDicts.en-us
      hyphenDicts.de-de
      hyphenDicts.en-us
      inkscape
      krita
      libreoffice
      remmina
      shfmt
      pkgs.unstable.signal-desktop
      pkgs.unstable.spotify
      pkgs.unstable.vscode
      swtpm
      vlc
      ydotool-paste
      zotero
    ];
  # networking.firewall = {
  #   allowedTCPPorts = [ 7236 7250 ]; # gnome-network-displays
  #   allowedUDPPorts = [ 7236 5353 ]; # gnome-network-displays
  #   # Firewall ports used by Steam in-home streaming.

  # };
  networking.firewall.allowedTCPPorts = [
    27036
    27037
  ];
  networking.firewall.allowedUDPPorts = [
    27031
    27036
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
  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      extraProfile = ''
        # Fixes timezones on VRChat
        unset TZ
        # Allows Monado to be used
        export PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES=1
      '';
    };
  };
  services.lact.enable = true;

  programs.vscode = {
    enable = true;
    package = pkgs.unstable.vscodium;
    extensions = with pkgs.unstable.nix-vscode-extensions.vscode-marketplace; [
      catppuccin.catppuccin-vsc

      ggml-org.llama-vscode

      jnoortheen.nix-ide

      mkhl.direnv
      mkhl.shfmt

      charliermarsh.ruff
      ms-python.python
      ms-toolsai.jupyter

      ms-azuretools.vscode-containers
      ms-vscode-remote.remote-containers
      ms-vscode-remote.remote-ssh
      ms-vscode-remote.remote-ssh-edit
      ms-vscode-remote.vscode-remote-extensionpack
      ms-vscode.remote-explorer
      ms-vscode.remote-server

      timonwong.shellcheck
    ];
  };

  # Enable sound
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

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

  # Disable suspend and hibernate
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';
}
