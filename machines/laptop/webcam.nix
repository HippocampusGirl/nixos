{ pkgs, ... }:
{
  boot.kernelPatches = [{
    name = "amd-isp4";
    patch = pkgs.stdenv.mkDerivation {
      pname = "amd-isp4";
      version = "v7";

      src = pkgs.fetchurl {
        url = "https://lore.kernel.org/all/20251216091326.111977-1-Bin.Du@amd.com/t.mbox.gz";
        hash = "sha256-dehwTyJyO18xZY1oyhQoyV9zV02m9WhqobivuZ+pydM=";
      };
      
      dontUnpack = true;

      nativeBuildInputs = with pkgs; [ b4 git gzip ];
      buildPhase = ''
        export XDG_CACHE_HOME=$PWD/.cache XDG_DATA_HOME=$PWD/.local
        zcat $src | b4 --offline-mode am --no-cache --use-local-mbox - --mbox-name patch
      '';
      installPhase = "cp patch.mbx $out";
    };
  }];
}
