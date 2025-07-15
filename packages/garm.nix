{ config, lib, pkgs, utils, ... }:
with lib;
let
  toml = pkgs.formats.toml { };

  cfg = config.services.garm;
  buildCloudbaseModule = pname: version: sha256: { checkFlags ? [ ] }:
    pkgs.buildGo124Module rec {
      inherit pname version checkFlags;
      src = pkgs.fetchFromGitHub {
        owner = "cloudbase";
        repo = pname;
        rev = version;
        sha256 = sha256;
      };
      vendorHash = null;
    };
  garm = buildCloudbaseModule "garm" "v0.1.5" "sha256-6kIULhL2NtyfduEYlApHLuwKdWEPVgcxdJ/zsLSh7AQ=" {
    checkFlags = [ "-tags=testing" ];
  };

  providerExecutables = {
    incus = ''${buildCloudbaseModule "garm-provider-incus" "v0.1.1" "sha256-G/CdsiDohjan7QYi8gfrBm6lLWU8vrtugPkFVC/Mf9A=" { 
    }}/bin/garm-provider-incus'';
    openstack = ''${buildCloudbaseModule "garm-provider-openstack" "v0.1.1" "sha256-T/t1gpqe+oY5fmPQXA+MKF6v2fxRtoJQ8zHBRVy3K7s=" {
      checkFlags = [ "-tags=testing" ];
    }}/bin/garm-provider-openstack'';
  };

  statePath = "/etc/garm";
  configFiles = {
    config = cfg.config // {
      provider = lib.mapAttrsToList
        (name: provider: with provider;{
          inherit name description provider_type;
          external = {
            config_file = "${statePath}/${name}.toml";
            provider_executable = builtins.getAttr provider.type providerExecutables;
          };
        })
        cfg.providers;
    };
  } // lib.mapAttrs (name: provider: provider.config) cfg.providers;
in
{
  options = {
    services.garm = {
      enable = mkEnableOption "Enable GitHub Actions Runner Manager";
      config = mkOption {
        type = toml.type;
        default = { };
        description = ''
          Configuration options for the GitHub Actions Runner Manager.

          Options containing secret data should be set to an attribute
          set containing the attribute `_secret` - a string pointing
          to a file containing the value the option should be set
          to. See the example to get a better picture of this: in the
          resulting configuration file, the
          `object_storage.s3.aws_secret_access_key` key will be set to
          the contents of the {file}`/var/keys/aws_secret_access_key`
          file.
        '';
      };
      providers = mkOption {
        type = types.attrsOf
          (types.submodule {
            options = {
              description = mkOption {
                type = types.str;
                default = "";
              };
              provider_type = mkOption {
                type = types.enum [ "external" ];
                default = "external";
              };
              type = mkOption {
                type = types.enum (lib.attrNames providerExecutables);
              };
              config = mkOption {
                type = toml.type;
                default = { };
              };
            };
          });
        default = { };
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ garm pkgs.e2fsprogs ];
    systemd.services.garm = {
      description = "GitHub Actions Runner Manager";
      wantedBy = [ "multi-user.target" ];
      requires = [ "network-online.target" ];
      after = [ "network-online.target" ];

      path = with pkgs; [
        remarshal
      ];
      serviceConfig = {
        ExecStartPre = pkgs.writeShellScript "garm-pre-start" (
          ''
            mkdir -p ${statePath}
            
            ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: c: ''
              ${utils.genJqSecretsReplacementSnippet c "${statePath}/${name}.json"}
              json2toml "${statePath}/${name}.json" "${statePath}/${name}.toml"
              rm "${statePath}/${name}.json"
            '') configFiles)}
          ''
        );
        ExecStart = "${garm}/bin/garm";
      };
    };
    users = {
      users.garm = {
        createHome = false;
        isSystemUser = true;
        group = "garm";
        extraGroups = [ "incus" ];
      };
      groups.garm = { };
    };
    virtualisation.incus.enable = true;
  };
}
