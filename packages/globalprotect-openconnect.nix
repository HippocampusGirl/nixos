{ pkgs, lib, ... }: pkgs.buildRustPackage rec {
  pname = "globalprotect-openconnect";
  version = "2.3.1";

  src = pkgs.fetchFromGitHub {
    owner = "yuezk";
    repo = "GlobalProtect-openconnect";
    rev = "v${version}";
    hash = lib.fakeHash;
  };

  cargoHash = lib.fakeHash; # You will also fill this in after the first build attempt
  meta = with lib; {
    description = "GlobalProtect VPN client (GUI) for Linux based on OpenConnect that supports SAML auth mode";
    homepage = "https://github.com/yuezk/GlobalProtect-openconnect";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
