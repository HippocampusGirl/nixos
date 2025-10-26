{ lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "sr_mod" "virtio_blk" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "mode=755" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/A9E1-981F";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  fileSystems."/nix" = {
    device = "z/nix";
    fsType = "zfs";
  };

  fileSystems."/persist" = {
    device = "z/persist";
    fsType = "zfs";
    neededForBoot = true;
  };

  fileSystems."/tmp" = {
    device = "z/tmp";
    fsType = "zfs";
    neededForBoot = true;
  };

  swapDevices =
    [{ device = "/dev/disk/by-partuuid/2e8808f5-4b89-4735-8a12-3a08c016ac68"; }];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
