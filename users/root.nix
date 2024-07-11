{ lib, config, ... }: {
  users.users.root = {
    hashedPasswordFile = config.sops.secrets."users/lea/hashed-password".path;
    subUidRanges = lib.mkForce [{
      startUid = 10000000;
      count = 1000000;
    }];
    subGidRanges = lib.mkForce [{
      startGid = 10000000;
      count = 1000000;
    }];
  };
  sops = {
    secrets."users/root/hashed-password" = {
      neededForUsers = true;
      sopsFile = ./secrets.yaml;
    };
  };
}
