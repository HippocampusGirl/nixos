{ lib, config, pkgs, ... }: {
  imports = [ ./airplay.nix ./wireless-networks.nix ];

  boot = {
    loader.raspberryPi.firmwareConfig = ''
      dtoverlay=hifiberry-dac
      dtoverlay=i2s-mmap
    '';
  };

  environment.systemPackages = with pkgs; [ wirelesstools wpa_supplicant ];

  hardware.firmware = [ pkgs.raspberrypiWirelessFirmware ];

  networking.wireless = {
    enable = true;
    interfaces = [ "wlan0" ];
    networks = { lealealea = { }; };
  };

  nixpkgs = {
    config.allowUnsupportedSystem = true;
    buildPlatform.system = "x86_64-linux";
    hostPlatform = lib.systems.examples.raspberryPi // {
      gcc = {
        arch = "armv6k";
        fpu = "vfpv2";
        tune = "arm1176jzf-s";
      };
    };
  };

  sdImage.compressImage = false;

  services.fstrim.enable = true;

  sound = {
    enable = true;
    # Taken from https://learn.adafruit.com/adafruit-i2s-audio-bonnet-for-raspberry-pi/raspberry-pi-usage
    extraConfig = ''
      pcm.speakerbonnet {
         type hw card 0
      }
      pcm.dmixer {
         type dmix
         ipc_key 1024
         ipc_perm 0666
         slave {
           pcm "speakerbonnet"
           period_time 0
           period_size 1024
           buffer_size 8192
           rate 44100
           channels 2
         }
      }
      ctl.dmixer {
          type hw card 0
      }
      pcm.softvol {
          type softvol
          slave.pcm "dmixer"
          control.name "PCM"
          control.card 0
      }
      ctl.softvol {
          type hw card 0
      }
      pcm.!default {
          type             plug
          slave.pcm       "softvol"
      }
    '';
  };

  system = {
    # Enable automatic security updates
    autoUpgrade = {
      enable = true;
      allowReboot = false;
      dates = "daily UTC";
    };
    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    stateVersion = "23.11"; # Did you read the comment?
  };
}
