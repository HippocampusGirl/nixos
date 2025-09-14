{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    nixpkgs.url = "github:nixos/nixpkgs/release-25.05";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    upload = {
      url = "github:HippocampusGirl/upload";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };
  outputs =
    { self
    , flake-utils
    , home-manager
    , impermanence
    , nixpkgs
    , sops-nix
    , upload
    , lanzaboote
    , nixpkgs-unstable
    }:
    let
      system = "x86_64-linux";
    in
    {
      nixosModules = {
        default = { config, ... }: {
          imports = [
            ./modules/acme.nix
            ./modules/command-not-found.nix
            ./modules/direnv.nix
            ./modules/docker.nix
            ./modules/fhs.nix
            ./modules/git.nix
            ./modules/gnupg.nix
            ./modules/htop.nix
            ./modules/i18n.nix
            ./modules/less.nix
            ./modules/mtr.nix
            ./modules/neovim.nix
            ./modules/nix-daemon.nix
            ./modules/nix-ld.nix
            ./modules/packages.nix
            ./modules/singularity.nix
            ./modules/tailscale.nix
            ./modules/tmux.nix
            ./modules/zram.nix
            ./modules/zrepl.nix
            ./users/lea.nix
            {
              system.autoUpgrade.flake = self.outPath;
              nixpkgs.overlays = [
                (import ./packages/bundle2jwks.nix)
                (import ./packages/vuescan.nix)
                (final: prev: {
                  unstable = import nixpkgs-unstable {
                    inherit system;
                    config = {
                      allowUnfree = true;
                    };
                  };
                })
              ];
            }
          ];
        };
        server = { config, ... }: {
          imports = [
            self.nixosModules.default
            ./modules/impermanence.nix
            ./modules/incus.nix
            ./modules/paranoid.nix
            ./modules/resolved.nix
            ./modules/zfs.nix
            ./users/root.nix
            impermanence.nixosModules.impermanence
            sops-nix.nixosModules.sops
            upload.nixosModules.upload
          ];
        };
        laptop = { config, ... }: {
          imports = [
            self.nixosModules.default
            ./modules/impermanence.nix
            ./modules/zfs.nix
            ./users/root.nix
            impermanence.nixosModules.impermanence
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            lanzaboote.nixosModules.lanzaboote
          ];
        };
      };
      nixosConfigurations = {
        laptop = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ self.nixosModules.laptop ./machines/laptop/configuration.nix ];
        };
        server = nixpkgs.lib.nixosSystem {
          inherit system;
          modules =
            [
              self.nixosModules.server
              ./modules/postgres.nix
              ./machines/server/configuration.nix
            ];
        };
        home = nixpkgs.lib.nixosSystem {
          inherit system;
          modules =
            [ self.nixosModules.server ./machines/home/configuration.nix ];
        };
        desktop = nixpkgs.lib.nixosSystem {
          inherit system;
          modules =
            [ self.nixosModules.server ./machines/desktop/configuration.nix ];
        };
      };
    } // flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
      };
    in
    {
      packages = {
        garm = pkgs.callPackage ./packages/garm.nix { };
      };
      devShells = {
        default =
          pkgs.mkShell { buildInputs = with pkgs; [ nil nixd nixpkgs-fmt ruff python3 ]; };
      };
    });
}
