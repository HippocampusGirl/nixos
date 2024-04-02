{ config, pkgs, ... }: {
  users.groups.nix-remote = { };
  users.users.nix-remote = {
    home = "/var/lib/nix-remote";
    createHome = true;

    group = "nix-remote";

    isSystemUser = true;
    useDefaultShell = true;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ8gtRG+ddAQ7kStqYw+/soV0iT33cJHaFaKHcudisKn"
    ];
  };
  nix.settings.trusted-users = [ "nixremote" ];
}
