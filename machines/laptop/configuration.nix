# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ ... }:

{
  imports =
    [
      # Include the results of the hardware scan
      ./hardware-configuration.nix
      ./secure-boot.nix
      ./vscode.nix
    ];

  # Use the systemd-boot EFI boot loader
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
    };
  };

  console = {
    font = "Lat2-Terminus16";
    # keyMap = "us";
    useXkbConfig = true; # use xkb.options in tty.
  };

  hardware = {
    nvidia = {
      modesetting.enable = true;
      open = false;
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA 
        nvidiaBusId = "PCI:1:0:0";
        # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA 
        intelBusId = "PCI:0:2:0";
      };
    };

    opengl.enable = true;

    pulseaudio.enable = false;
  };


  # Select internationalisation properties
  i18n.defaultLocale = "en_US.UTF-8";

  networking = {
    hostId = "1ea1ea12";
    hostName = "laptop";
    firewall.enable = true;
    networkmanager.enable = true;
    nftables.enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  powerManagement.enable = true;

  services = {
    # Enable touchpad support (enabled default in most desktopManager)
    libinput.enable = true;

    # Enable sound
    pipewire = {
      enable = true;

      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Enable CUPS to print documents
    printing.enable = true;

    # Enable the X11 windowing system
    xserver = {
      enable = true;

      # Enable the GNOME Desktop Environment
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;

      videoDrivers = [ "nvidia" ];

      # Configure keymap in X11
      xkb = { layout = "us"; options = "eurosign:e,caps:escape"; };
    };
  };

  sops = {
    # This is using an age key that is expected to already be in the filesystem
    age.keyFile = "/var/lib/sops/key.txt";
  };

  # This option defines the firste this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than th version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?

  time = {
    timeZone = "Europe/Berlin";
    hardwareClockInLocalTime = true;
  };
}

