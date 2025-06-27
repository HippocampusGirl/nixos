{ config, lib, pkgs, utils, ... }:
with lib;
let
  toml = pkgs.formats.toml { };

  cfg = config.services.garm;
  buildCloudbaseModule = pname: version: sha256: { checkFlags ? [ ] }:
    pkgs.buildGo123Module rec {
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
    lxd = ''${buildCloudbaseModule "garm-provider-lxd" "v0.1.0" "sha256-pzyqfuphBKGgR6o1AK1cEdhM+J3OBrKw7LaWq/XgDMA=" { 
    }}/bin/garm-provider-lxd'';
    openstack = ''${buildCloudbaseModule "garm-provider-openstack" "v0.1.0" "sha256-tQtzLelEcfIj2c7xACTS7sJA62KfbIT4xaZpTmLD5fE=" {
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
    systemd.services.lxd.path = [ pkgs.e2fsprogs ];
    users = {
      users.garm = {
        createHome = false;
        isSystemUser = true;
        group = "garm";
        extraGroups = [ "lxd" ];
      };
      groups.garm = { };
    };
    virtualisation.lxd.enable = true;
  };
}
