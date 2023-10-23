{ lib, ... }: {
  imports = [ ./root-password.nix ];
  users = {
    users.root = {
      subUidRanges = lib.mkForce [{
        startUid = 10000000;
        count = 1000000;
      }];
      subGidRanges = lib.mkForce [{
        startGid = 10000000;
        count = 1000000;
      }];
    };
  };
}
