{
  nix = {
    buildMachines = [{
      hostName = "server.lea";
      system = "x86_64-linux";

      protocol = "ssh";
      sshUser = "nix-remote";
      sshKey = "/root/.ssh/id_ed25519";

      maxJobs = 4;

      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" ];
      mandatoryFeatures = [ ];
    }];
  };
}
