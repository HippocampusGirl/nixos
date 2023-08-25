{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.dockerAuth;
  dockerAuth = pkgs.buildGo118Module rec {
    pname = "dockerAuth";
    version = "1.11.0";
    src = pkgs.fetchFromGitHub {
      owner = "cesanta";
      repo = "docker_auth";
      rev = version;
      sha256 =
        "sha256-IPp4Bz8xW9BSo0mkmgTt0g1fZ9IWRX3WGie0moq5860="; # lib.fakeSha256
    };
    sourceRoot = "source/auth_server";
    ldflags = [ "-X main.Version=${version}" "-X main.BuildID=${version}" ];
    patches = [ ./fix-docker-auth-go-version.patch ];
    vendorSha256 = "sha256-uxoJsj4YsiJC76sAgme85OpQEChwAjFmLzQP+udGp5g=";
  };
  authConfig = {
    server = {
      addr = cfg.listenAddress;
      net = cfg.net;
    };
    token = cfg.token;
    users = lib.mapAttrs (user: configuration:
      (lib.listToAttrs (lib.concatMap (name:
        let value = configuration.${name};
        in if name == "password" && value != null then
          [ (lib.nameValuePair "password" value) ]
        else
          (if name == "passwordFile" && value != null then
            [
              (lib.nameValuePair "password" "$(cat ${value})")
            ]
          else
            [ ])) (lib.attrNames configuration)))) cfg.users;
    acl = cfg.acl;
  };
  configJSON = builtins.toJSON (recursiveUpdate authConfig cfg.extraConfig);
  configureScript = pkgs.writeShellScriptBin "docker-auth-configure" (''
    cat > /var/lib/docker-auth/config.yaml <<EOF
    ${configJSON}
    EOF
    chown docker-auth:docker-auth /var/lib/docker-auth/config.yaml
    chmod 755 /var/lib/docker-auth
    chmod 700 /var/lib/docker-auth/config.yaml
    chmod 755 ${cfg.token.certificate}
  '');

in {
  options = {
    services.dockerAuth = {
      enable = mkEnableOption "Enable Docker Registry 2 Authentication Server";
      listenAddress = mkOption {
        description = lib.mdDoc ''
          Address to listen on. Can be HOST:PORT for TCP or 
          file path (e.g. /run/docker_auth.sock) for Unix socket.'';
        default = ":5001";
        type = types.str;
      };
      net = mkOption {
        description = lib.mdDoc "Network to listen on. Can be tcp or unix.";
        default = "tcp";
        type = types.enum [ "tcp" "unix" ];
      };
      users = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            password = mkOption {
              type = types.nullOr types.str;
              default = null;
            };
            passwordFile = mkOption {
              type = types.nullOr types.path;
              default = null;
            };
          };
        });
        description = mdDoc ''
          Static user map. Password is specified as a BCrypt hash. 
          Use `htpasswd -nB USERNAME` to generate.
        '';
      };
      token = mkOption {
        type = types.submodule {
          options = {
            issuer = mkOption {
              type = types.str;
              description = "Must match issuer in the Registry config";
              default = "Acme auth server";
            };
            expiration = mkOption {
              type = types.int;
              default = 900;
            };
            certificate = mkOption {
              type = types.path;
              description = mdDoc ''
                Generate using
                ```bash
                openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
                  -subj "/C=DE/ST=Berlin/L=Berlin/O=lea.science/CN=cr.lea.science" \
                  -keyout server.key \
                  -out server.pem
                ```
              '';
            };
            key = mkOption { type = types.path; };
          };
        };
        description = mdDoc ''
          Settings for the tokens
        '';
      };
      acl = mkOption {
        type = types.nonEmptyListOf (types.submodule {
          options = {
            match = mkOption { type = types.attrs; };
            actions = mkOption { type = types.nonEmptyListOf types.str; };
            comment = mkOption {
              type = types.nullOr types.str;
              default = null;
            };
          };
        });
        description = mdDoc ''
          ACL specifies who can do what. If the match section of an entry matches the
          request, the set of allowed actions will be applied to the token request
          and a ticket will be issued only for those of the requested actions that are
          allowed by the rule.
          * It is possible to match on user's name ("account"), subject type ("type")
            and name ("name"; for type=repository this is the image name).
          * Matches are evaluated as shell file name patterns ("globs") by default,
            so "foobar", "f??bar", "f*bar" are all valid. For even more flexibility
            match patterns can be evaluated as regexes by enclosing them in //, e.g.
            "/(foo|bar)/".
          * IP match can be single IP address or a subnet in the "prefix/mask" notation.
          * ACL is evaluated in the order it is defined until a match is found.
            Rules below the first match are not evaluated, so you'll need to put more
            specific rules above more broad ones.
          * Empty match clause matches anything, it only makes sense at the end of the
            list and can be used as a way of specifying default permissions.
          * Empty actions set means "deny everything". Thus, a rule with `actions: []`
            is in effect a "deny" rule.
          * A special set consisting of a single "*" action means "allow everything".
          * If no match is found the default is to deny the request.

          You can use the following variables from the ticket request in any field:
          * ''${account} - the account name, currently the same as authenticated user's name.
          * ''${service} - the service name, specified by auth.token.service in the registry config.
          * ''${type} - the type of the entity, normally "repository".
          * ''${name} - the name of the repository (i.e. image), e.g. centos.
          * ''${labels:<LABEL>} - tests all values in the list of lables:<LABEL> for the user. 
            Refer to the labels doc for details
        '';
        default = { };
      };
      extraConfig = mkOption {
        description = lib.mdDoc ''
          Docker extra registry configuration via environment variables.
        '';
        default = { };
        type = types.attrs;
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [ dockerAuth pkgs.jq ];

    system.activationScripts.makeDockerAuthDir = lib.stringAfter [ "users" ] ''
      mkdir -m 0755 -p /var/lib/docker-auth
      chown docker-auth:docker-auth /var/lib/docker-auth
    '';

    systemd.services.docker-auth = {
      description = "Docker Registry Authentication Server";
      wantedBy = [ "multi-user.target" ];
      requires = [ "network-online.target" ];
      after = [ "network-online.target" ];

      serviceConfig = {
        User = "docker-auth";
        ExecStartPre = "!${configureScript}/bin/docker-auth-configure";
        ExecStart =
          "${dockerAuth}/bin/auth_server /var/lib/docker-auth/config.yaml";
      };
    };

    users.users.docker-auth = {
      home = "/var/lib/docker-auth";
      createHome = true;
      group = "docker-auth";
      isSystemUser = true;
      useDefaultShell = true;
    };
    users.groups.docker-auth = { };
  };
}
