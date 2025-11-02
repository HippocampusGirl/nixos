{ config, lib, pkgs, ... }:
let
  zerofs = pkgs.rustPlatform.buildRustPackage.override
    {
      rustc = pkgs.unstable.rustc;
      cargo = pkgs.unstable.cargo;
    }
    rec {
      pname = "zerofs";
      version = "0.16.2";

      src = pkgs.fetchFromGitHub {
        owner = "Barre";
        repo = "ZeroFS";
        tag = "v${version}";
        hash = "sha256-NJ/lQ0zE2mPSCfRlbIthhytaGKXQgM2xy3UC5uRfADA=";
      };

      sourceRoot = "${src.name}/zerofs";

      cargoHash = "sha256-Hw6PRgOk2Ub7W0ARnCxNYxGeZ7d4bhMgKPCUn13fvhg=";

      meta = {
        description = "The Filesystem That Makes S3 your Primary Storage. ZeroFS is 9P/NFS/NBD on top of S3.";
        homepage = "https://github.com/Barre/ZeroFS";
        license = lib.licenses.agpl3Plus;
        mainProgram = "zerofs";
        maintainers = with lib.maintainers; [ misuzu ];
        platforms = lib.platforms.unix;
      };
    };

  cfg = config.services.zerofs;
  settingsFormat = pkgs.formats.toml { };
  configFile = settingsFormat.generate "zerofs.toml" (
    lib.filterAttrsRecursive (name: value: value != null) cfg.settings
  );
in
{
  options = {
    services.zerofs = with lib; {
      enable = mkEnableOption "Enable ZeroFS service";

      settings = mkOption {
        type = types.attrs;
        description = "ZeroFS settings.";
        default = { };
      };

      environmentFile = mkOption {
        type = types.nullOr types.path;
        description = ''
          Environment file as defined in {manpage}`systemd.exec(5)`.

          See documentation <https://www.zerofs.net/configuration#environment-variable-substitution>.
        '';
        default = null;
      };
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services.zerofs =
      let
        depends-on =
          [ "network.target" "network-online.target" ];
      in
      {
        description = "ZeroFS";

        after = depends-on;
        wants = depends-on;
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;

          ExecStart = "${lib.getExe zerofs} run --config ${configFile}";

          Restart = "always";
          RestartSec = "5s";
          DynamicUser = true;

          Group = "zerofs";
          User = "zerofs";
        };
      };
    users = {
      users.zerofs = {
        createHome = false;
        isSystemUser = true;
        group = "zerofs";
      };
      groups.zerofs = { };
    };
  };
}
