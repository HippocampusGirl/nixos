{
  services.bitcoind.default = {
    enable = true;

    user = "bitcoin";
    group = "bitcoin";

    dataDir = "/z/bitcoin";

    dbCache = 1024;
    extraConfig = ''
      maxconnections=16
      maxuploadtarget=1024
    '';

    rpc.users.lea.passwordHMAC =
      "be686e9454ee579d214fda65a09e5a74$1e0b66843168daf3c6936ec5842c846b5ef0d479dd12bde5696d19f31ce5255d";
  };
}
