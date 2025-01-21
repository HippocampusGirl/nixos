final: prev:
let
  pkgs = prev.pkgs;
in
{
  bundle2jwks = pkgs.buildGo122Module {
    pname = "bundle2jwks";
    version = "git";
    src = pkgs.fetchFromGitHub {
      owner = "brandond";
      repo = "bundle2jwks";
      rev = "9257c1b0f568bd3a97ae1c9c8cf93edcfe82d506";
      sha256 = "sha256-LChfuEIHs6PoVeWz9t8bAsqAq8pxRHQBEAT/hbZMHJw=";
    };
    vendorHash = "sha256-xhhLP5RrXdP4wwhqHm/quVyp+uimeo8BZI6wiCf8src=";
  };
}
