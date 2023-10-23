{ pkgs, lib ... }: {
  boot.zfs.enableUnstable = true;
  boot.zfs.requestEncryptionCredentials = true;
  boot.supportedFilesystems = [ "zfs" ];
  networking.hostId = "13413400";
  environment.systemPackages = [
    pkgs.mbuffer # for sending
  ];
}