{ lib, config, pkgs, ... }:
let name = "optuna"; in {
  services = {
    postgresql = {
      enable = lib.mkForce true;
      ensureDatabases = [ name ];
      ensureUsers = [{
        name = name;
        ensureDBOwnership = true;
      }];

      authentication = lib.mkForce ''
        local all all trust
        host ${name} ${name} 127.0.0.1/32 trust
        host ${name} ${name} ::1/128 trust
      '';
    };
    redis = {
      package = pkgs.valkey;
      servers."".enable = true;
    };
  };
  users.groups.${name} = { };
  users.users.${name} = {
    isNormalUser = true;
    group = "${name}";

    openssh.authorizedKeys.keys = config.users.extraUsers.lea.openssh.authorizedKeys.keys ++ [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMofOuXAKUAfNaRaXo3fmD/p/5U08zSslCmvOr6jGWJU"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGR0FyCn7EKsO9kQ5mg8JjAG1aVWSa3xvUnFpX0dvhqD"
    ];
  };
}
