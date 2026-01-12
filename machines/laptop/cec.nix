{ pkgs, ... }: {
  services.udev.extraRules = ''
    SUBSYSTEM=="tty", KERNEL=="ttyACM[0-9]*", ATTRS{idVendor}=="2548", ATTRS{idProduct}=="1002", ACTION=="add", TAG+="systemd", ENV{SYSTEMD_WANTS}+="pulse8-cec-inputattach@%k.service"
    # Force device to be reconfigured when reset after suspend, otherwise the ttyACM link is lost but udev will not notice.
    # A usb_dev_uevent with DEVNUM=000 is a sign that the device is being reset before enumeration.
    # Re-configuring causes ttyACM to be removed and re-added instead.
    SUBSYSTEM=="usb", ATTRS{idVendor}=="2548", ATTRS{idProduct}=="1002", ACTION=="change", ENV{DEVNUM}=="000", ATTR{bConfigurationValue}="1"  
  '';

  environment.systemPackages = with pkgs; [
    libcec
  ];

  boot.kernelPatches = [{
    name = "pulse8-cec-module";
    patch = null;
    extraConfig = ''
      MEDIA_CEC_SUPPORT y
      USB_PULSE8_CEC m
    '';
  }];

  systemd.services = {
    "cec-poweroff-tv" = {
      description = "=Use CEC to power off TV";
      wantedBy = [ "poweroff.target" ];
      serviceConfig =
        let
          script = pkgs.writeShellScript "cec-tv-off" ''
            ${pkgs.libcec}/bin/cec-client --single-command --log-level 1 <<EOF
            standby 0
            EOF
          '';
        in
        {
          Type = "oneshot";
          ExecStart = script;
          ExecStop = script;
        };
    };
  };

}
