{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.garm;
  garm = pkgs.buildGo120Module rec {
    pname = "garm";
    version = "v0.1.3";
    src = pkgs.fetchFromGitHub {
      owner = "cloudbase";
      repo = pname;
      rev = version;
      sha256 = "sha256-i32zyXRFZVz9dlrPHkh7w7rruPlH3Rs1vjyCXd0lzKc=";
    };
    patches = [
      ./fix-garm-cloudconfig-selinux.patch
    ];
    vendorHash = null;
  };
  configureScript = pkgs.writeShellScriptBin "garm-configure" (''
    mkdir -p /etc/garm
    cat <<EOF > /etc/garm/config.toml
    [default]
    callback_url = "${cfg.callbackUrl}"
    metadata_url = "${cfg.metadataUrl}"
    config_dir = "${cfg.configDir}"
    enable_log_streamer = ${if cfg.logStreamer.enable then "true" else "false"}

    [metrics]
    enable = ${if cfg.metrics.enable then "true" else "false"}

    [jwt_auth]
    secret = "$(cat ${cfg.jwtAuth.secretFile})"
    time_to_live = "${cfg.jwtAuth.timeToLive}"

    [apiserver]
      bind = "${cfg.apiServer.bind}"
      port = ${toString cfg.apiServer.port}
      use_tls = ${if cfg.apiServer.tls.enable then "true" else "false"}

      cors_origins = ["${concatStringsSep ''", "'' cfg.apiServer.corsOrigins}"]
      [apiserver.tls]
        ${
          optionalString (cfg.apiServer.tls.certFile != null) ''
            certificate = "${cfg.apiServer.tls.certFile}"
          ''
        }
        ${
          optionalString (cfg.apiServer.tls.keyFile != null) ''
            key = "${cfg.apiServer.tls.keyFile}"
          ''
        }

    [database]
      debug = ${if cfg.database.debug then "true" else "false"}
      backend = "sqlite3"
      passphrase = "$(cat ${cfg.database.passphraseFile})"
      [database.sqlite3]
        # Path on disk to the sqlite3 database file.
        db_file = "${cfg.configDir}/garm.db"

    # Currently, providers are defined statically in the config. This is due to the fact
    # that we have not yet added support for storing secrets in something like Barbican
    # or Vault. This will change in the future. However, for now, it's important to remember
    # that once you create a pool using one of the providers defined here, the name of that
    # provider must not be changes, or the pool will no longer work. Make sure you remove any
    # pools before removing or changing a provider.
    [[provider]]
      # An arbitrary string describing this provider.
      name = "lxd_local"
      # Provider type. Garm is designed to allow creating providers which are used to spin
      # up compute resources, which in turn will run the github runner software.
      # Currently, LXD is the only supprted provider, but more will be written in the future.
      provider_type = "lxd"
      # A short description of this provider. The name, description and provider types will
      # be included in the information returned by the API when listing available providers.
      description = "Local LXD installation"
      [provider.lxd]
        # the path to the unix socket that LXD is listening on. This works if garm and LXD
        # are on the same system, and this option takes precedence over the "url" option,
        # which connects over the network.
        unix_socket_path = "/var/lib/lxd/unix.socket"
        # When defining a pool for a repository or an organization, you have an option to
        # specify a "flavor". In LXD terms, this translates to "profiles". Profiles allow
        # you to customize your instances (memory, cpu, disks, nics, etc).
        # This option allows you to inject the "default" profile along with the profile selected
        # by the flavor.
        include_default_profile = false
        instance_type = "${cfg.lxd.instanceType}"
        # enable/disable secure boot. If the image you select for the pool does not have a
        # signed bootloader, set this to false, otherwise your instances won't boot.
        secure_boot = false
        # Project name to use. You can create a separate project in LXD for runners.
        project_name = "${cfg.lxd.project}"
        [provider.lxd.image_remotes]
          # Image remotes are important. These are the default remotes used by lxc. The names
          # of these remotes are important. When specifying an "image" for the pool, that image
          # can be a hash of an existing image on your local LXD installation or it can be a
          # remote image from one of these remotes. You can specify the images as follows:
          # Example:
          #
          #    * ubuntu:20.04
          #    * ubuntu_daily:20.04
          #    * images:centos/8/cloud
          #
          # Ubuntu images come pre-installed with cloud-init which we use to set up the runner
          # automatically and customize the runner. For non Ubuntu images, you need to use the
          # variant that has "/cloud" in the name. Those images come with cloud-init.
          [provider.lxd.image_remotes.ubuntu]
            addr = "https://cloud-images.ubuntu.com/releases"
            public = true
            protocol = "simplestreams"
            skip_verify = false
          [provider.lxd.image_remotes.ubuntu_daily]
            addr = "https://cloud-images.ubuntu.com/daily"
            public = true
            protocol = "simplestreams"
            skip_verify = false
          [provider.lxd.image_remotes.images]
            addr = "https://images.linuxcontainers.org"
            public = true
            protocol = "simplestreams"
            skip_verify = false

    ${concatStringsSep "\n" (mapAttrsToList (name: value: ''
      [[github]]
      name = "${name}"
      ${optionalString (value.description != null) ''
        description = "${value.description}"
      ''}
      oauth2_token = "$(cat ${value.tokenFile})"
    '') cfg.github)}
    EOF
  '');
in {
  options = {
    services.garm = {
      enable = mkEnableOption "Enable GitHub Actions Runner Manager";

      configDir = mkOption {
        type = types.path;
        description = mdDoc ''
          This folder is defined here for future use. Right now, we create a SSH
          public/private key-pair.
        '';
        default = "/var/lib/garm";
      };

      callbackUrl = mkOption {
        type = types.str;
        description = mdDoc ''
          This URL is used by instances to send back status messages as they install
          the github actions runner. Status messages can be seen by querying the
          runner status in garm.
          Note: If you're using a reverse proxy in front of your garm installation,
          this URL needs to point to the address of the reverse proxy. Using TLS is
          highly encouraged.
        '';
      };
      metadataUrl = mkOption {
        type = types.str;
        description = mdDoc ''
          This URL is used by instances to send back status messages as they install
          the github actions runner. Status messages can be seen by querying the
          runner status in garm.
          Note: If you're using a reverse proxy in front of your garm installation,
          this URL needs to point to the address of the reverse proxy. Using TLS is
          highly encouraged.
        '';
      };

      logStreamer.enable = mkEnableOption {
        description =
          "Enable streaming logs via web sockets. Use garm-cli debug-log.";
      };
      metrics.enable = mkEnableOption {
        description = mdDoc ''
          Toggle metrics. If set to false, the API endpoint for metrics collection will
          be disabled.
        '';
      };

      jwtAuth.secretFile = mkOption {
        type = types.path;
        description =
          "A file containing the JWT token secret used to sign tokens.";
      };
      jwtAuth.timeToLive = mkOption {
        type = types.str;
        description = mdDoc ''
          Time to live for tokens. Both the instances and you will use JWT tokens to
          authenticate against the API. However, this TTL is applied only to tokens you
          get when logging into the API. The tokens issued to the instances we manage,
          have a TTL based on the runner bootstrap timeout set on each pool. The minimum
          TTL for this token is 24h.
        '';
        default = "8760h";
      };

      apiServer.bind = mkOption {
        type = types.str;
        description = "Bind the API to this IP";
        default = "0.0.0.0";
      };
      apiServer.port = mkOption {
        type = types.int;
        description = "Bind the API to this port";
        default = 8080;
      };
      apiServer.corsOrigins = mkOption {
        type = types.listOf types.str;
        description = mdDoc ''
          Set a list of allowed origins
          By default, if this option is ommited or empty, we will check
          only that the origin is the same as the originating server.
          A literal of "*" will allow any origin
        '';
        default = [ "*" ];
      };
      apiServer.tls.enable = mkEnableOption {
        description = mdDoc ''
          Whether or not to set up TLS for the API endpoint. If this is set to true,
          you must have a valid apiserver.tls section.
        '';
      };
      apiServer.tls.certFile = mkOption {
        type = types.nullOr types.path;
        description = mdDoc ''
          Path on disk to a x509 certificate bundle.
          NOTE: if your certificate is signed by an intermediary CA, this file
          must contain the entire certificate bundle needed for clients to validate
          the certificate. This usually means concatenating the certificate and the
        '';
        default = null;
      };
      apiServer.tls.keyFile = mkOption {
        type = types.nullOr types.path;
        description =
          "The path on disk to the corresponding private key for the certificate.";
        default = null;
      };

      database.debug =
        mkEnableOption "Turn on/off debugging for database queries.";
      database.passphraseFile = mkOption {
        type = types.path;
        description = mdDoc ''
          The passphrase option is a temporary measure by which we encrypt the webhook
          secret that gets saved to the database, using AES256. In the future, secrets
          will be saved to something like Barbican or Vault, eliminating the need for
          this. This setting needs to be 32 characters in size.
        '';
      };

      lxd.project = mkOption {
        type = types.str;
        description = "The name of the LXD project to use";
        default = "default";
      };
      lxd.instanceType = mkOption {
        type = types.enum [ "virtual-machine" "container" ];
        description =
          "instance_type defines the type of instances this provider will create.";
        default = "virtual-machine";
      };

      github = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            description = mkOption {
              type = types.nullOr types.str;
              description =
                "The description of the GitHub organization or repository";
              default = null;
            };
            tokenFile = mkOption {
              type = types.path;
              description = mdDoc ''
                This is a personal token with access to the repositories and organizations
                you plan on adding to garm. The "workflow" option needs to be selected in order
                to work with repositories, and the admin:org needs to be set if you plan on
                adding an organization.
              '';
            };
          };
        });
        description = mdDoc ''
          This is a list of credentials that you can define as part of the repository
          or organization definitions. They are not saved inside the database, as there
          is no Vault integration (yet). This will change in the future.
          Credentials defined here can be listed using the API. Obviously, only the name
          and descriptions are returned.
        '';
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

      serviceConfig = {
        ExecStartPre = "!${configureScript}/bin/garm-configure";
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
