# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ pkgs, lib, ... }:
{
  imports =
    [
      ./gnome.nix
      # Include the results of the hardware scan
      ./hardware-configuration.nix
      ./networking.nix
      ./nginx.nix
      ./secure-boot.nix
      ./zrepl.nix
    ];

  boot = {
    kernelPackages = pkgs.linuxPackages_6_16;
    kernelParams = [ "usbcore.autosuspend=-1" ];
    tmp.cleanOnBoot = true;
  };

  console = {
    useXkbConfig = true; # use xkb.options in tty
  };

  environment.systemPackages = with pkgs; [
    incus
    spice-gtk
  ];

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
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

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "discord"
      "vuescan"
      "zoom"
    ];

  powerManagement.enable = true;

  # A fuse filesystem that dynamically populates contents of /bin and /usr/bin/ so that
  # it contains all executables from the PATH of the requesting process. This allows
  # executing FHS based programs on a non-FHS system. For example, this is useful to
  #execute shebangs on NixOS that assume hard coded locations like /bin or /usr/bin etc.
  services.envfs.enable = true;

  sops = {
    # This is using an age key that is expected to already be in the filesystem
    age.keyFile = "/var/lib/sops/key.txt";
    defaultSopsFile = ./secrets.yaml;
  };

  time = { timeZone = "America/Montreal"; };

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    spiceUSBRedirection.enable = true;
  };
  services.spice-vdagentd.enable = true;

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
}

