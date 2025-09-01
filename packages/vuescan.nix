final: prev:
let
  lib = prev.lib;
  pkgs = prev.pkgs;
  stdenv = prev.stdenv;

  desktop-item = pkgs.makeDesktopItem {
    name = "VueScan";
    desktopName = "VueScan";
    genericName = "Scanning Program";
    comment = "Scanning Program";
    icon = "vuescan";
    terminal = false;
    type = "Application";
    startupNotify = true;
    categories = [ "Graphics" "Utility" ];
    keywords = [ "scan" "scanner" ];

    exec = "vuescan";
  };
in
{
  vuescan = stdenv.mkDerivation rec {
    pname = "vuescan";

    # Minor versions are released using the same file name
    version = "9.8.46";
    versionItems = builtins.splitVersion version;
    versionString = (builtins.elemAt versionItems 0) + (builtins.elemAt versionItems 1);

    src = pkgs.fetchurl {
      url = "https://www.hamrick.com/files/vuex64${versionString}.tgz";
      sha256 = "sha256-CJYc86Sod8EEpiIfPDWuBGGFSl0EzOBNS2LazQi2bQs=";
    };

    # Stripping the binary breaks the license form
    dontStrip = true;

    nativeBuildInputs = with pkgs; [
      gnutar
      autoPatchelfHook
    ];

    buildInputs = with pkgs; [
      glibc
      gtk3
      xorg.libSM
      libgudev
    ];

    unpackPhase = ''
      tar xfz $src
    '';

    installPhase = ''
      install -m755 -D VueScan/vuescan $out/bin/vuescan

      mkdir -p $out/share/icons/hicolor/scalable/apps/
      cp VueScan/vuescan.svg $out/share/icons/hicolor/scalable/apps/vuescan.svg 

      mkdir -p $out/lib/udev/rules.d/
      cp VueScan/vuescan.rul $out/lib/udev/rules.d/60-vuescan.rules

      mkdir -p $out/share/applications/
      ln -s ${desktop-item}/share/applications/* $out/share/applications
    '';


    meta = with lib; {
      homepage = "https://www.hamrick.com/about-vuescan.html";
      description = "Scanning software for film scanners";
      license = licenses.unfree;
      platforms = [ "x86_64-linux" ];
    };
  };
}
