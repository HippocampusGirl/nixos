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
    options = [
      "defaults"
      "mode=755"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/54C2-262E";
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
    [{ device = "/dev/disk/by-partuuid/6db2f512-eeec-4d11-818f-7181f00e680b"; }];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
