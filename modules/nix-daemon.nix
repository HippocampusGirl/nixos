{
  nix = {
    settings = {
      # Support for nix-direnv
      keep-outputs = true;
      keep-derivations = true;
      # Allow use by wheel group
      allowed-users = [ "@wheel" "root" ];
    };
    # Enable garbage collection every week
    gc = {
      automatic = true;
      dates = "Monday 01:00 UTC";
      options = "--delete-older-than 7d";
    };
    # Run garbage collection when disk is almost full
    extraOptions = ''
      min-free = ${toString (512 * 1024 * 1024)}
      experimental-features = nix-command flakes impure-derivations
    '';
  };
}
