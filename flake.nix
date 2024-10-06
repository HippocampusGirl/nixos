{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/release-24.05";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    upload = {
      url = "github:HippocampusGirl/upload";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };
  outputs =
    { self
    , flake-utils
    , home-manager
    , impermanence
    , nixos-wsl
    , nixpkgs
    , sops-nix
    , upload
    , vscode-server
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
            ./modules/fhs.nix
            ./modules/git.nix
            ./modules/htop.nix
            ./modules/i18n.nix
            ./modules/less.nix
            ./modules/mtr.nix
            ./modules/neovim.nix
            ./modules/nix-daemon.nix
            ./modules/nix-ld.nix
            ./modules/packages.nix
            ./modules/powertop.nix
            ./modules/resolved.nix
            ./modules/singularity.nix
            ./modules/tailscale.nix
            ./modules/tmux.nix
            ./modules/zram.nix
            ./modules/zrepl.nix
            ./users/lea.nix
            {
              system.autoUpgrade.flake = self.outPath;
              nixpkgs.overlays = [
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
            ./modules/lxd.nix
            ./modules/paranoid.nix
            ./modules/postgres.nix
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
        laptop-wsl = { config, ... }: {
          imports = [
            self.nixosModules.default
            ./modules/tex.nix
            home-manager.nixosModules.home-manager
            nixos-wsl.nixosModules.wsl
            sops-nix.nixosModules.sops
            vscode-server.nixosModules.default
          ];
        };
      };
      nixosConfigurations = {
        home = nixpkgs.lib.nixosSystem {
          inherit system;
          modules =
            [ self.nixosModules.server ./machines/home/configuration.nix ];
        };
        laptop = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ self.nixosModules.laptop ./machines/laptop/configuration.nix ];
        };
        laptop-wsl = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [ self.nixosModules.laptop-wsl ./machines/laptop-wsl/configuration.nix ];
        };
        server = nixpkgs.lib.nixosSystem {
          inherit system;
          modules =
            [ self.nixosModules.server ./machines/server/configuration.nix ];
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
          pkgs.mkShell { buildInputs = with pkgs; [ nil nixd nixpkgs-fmt ]; };
      };
    });
}
