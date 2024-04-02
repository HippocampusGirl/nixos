{ lib, config, ... }: {
  nix = {
    buildMachines = [
      (lib.mkIf (config.networking.hostName != "server") {
        hostName = "server.lea.science";
        system = "x86_64-linux";

        protocol = "ssh";
        sshUser = "nix-remote";
        sshKey = "/root/.ssh/id_ed25519";

        maxJobs = 4;

        supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" ];
        mandatoryFeatures = [ ];
      })
    ];
    distributedBuilds = true;
    extraOptions = ''
      builders-use-substitutes = true
      experimental-features = nix-command flakes impure-derivations
    '';
    # Enable garbage collection every week
    gc = {
      automatic = true;
      dates = "Monday 01:00 UTC";
      options = "--delete-older-than 30d";
    };
    settings = {
      # Support for nix-direnv
      keep-outputs = true;
      keep-derivations = true;
      # write the build log of derivations
      keep-build-log = true;
      # Keep building derivations when another build fails
      keep-going = true;
      # Keep temporary directories of failed builds
      keep-failed = true;
      # Allow use by wheel group
      allowed-users = [ "@wheel" "root" "nix-remote" ];
      trusted-users = [ "lea" "nix-remote" ];
      # Automatically merge duplicate files from the store
      auto-optimise-store = true;
    };
  };
}
