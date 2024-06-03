{ lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "mode=755" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/7FC3-2B8C";
    fsType = "vfat";
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
    [{ device = "/dev/disk/by-partuuid/3b349e04-b9d5-4341-afc1-dbe2979bb493"; }];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
