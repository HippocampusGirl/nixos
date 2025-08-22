{ pkgs, ... }: {
  # Allow running virtual machines
  boot = { kernelModules = [ "kvm-amd" "vhost_vsock" ]; };
  environment.systemPackages = with pkgs; [
    cdrkit
    distrobuilder
    hivex
    qemu
    wimlib
  ];
}
