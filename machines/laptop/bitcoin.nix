{
  services.bitcoind.default = {
    enable = true;

    user = "bitcoin";
    group = "bitcoin";

    dataDir = "/z/bitcoin";
  };
}
