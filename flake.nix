{
  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = { url = "github:nix-community/impermanence"; };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    upload = {
      url = "github:HippocampusGirl/upload";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = { url = "github:nix-community/nixos-vscode-server"; };
  };
  outputs = { self, nixpkgs, home-manager, impermanence, nixos-generators
    , nixos-wsl, sops-nix, upload, vscode-server }: {
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
            ./modules/neovim.nix
            ./modules/nix-daemon.nix
            ./modules/nix-ld.nix
            ./modules/packages.nix
            ./modules/powertop.nix
            ./modules/singularity.nix
            ./modules/tmux.nix
            ./modules/zram.nix
            ./modules/zsh.nix
            ./users/lea.nix
          ];
        };
        server = { config, ... }: {
          imports = [
            self.nixosModules.default
            ./modules/impermanence.nix
            ./modules/lxd.nix
            ./modules/paranoid.nix
            ./modules/tailscale.nix
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
            ./modules/tex.nix
            ./machines/laptop/configuration.nix
            home-manager.nixosModules.home-manager
            nixos-wsl.nixosModules.wsl
            sops-nix.nixosModules.sops
            vscode-server.nixosModules.default
          ];
        };
      };
      nixosConfigurations = {
        home = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules =
            [ self.nixosModules.server ./machines/home/configuration.nix ];
        };
        laptop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ self.nixosModules.laptop ];
        };
        server = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules =
            [ self.nixosModules.server ./machines/server/configuration.nix ];
        };
      };
      packages.x86_64-linux = {
        installer = nixos-generators.nixosGenerate {
          system = "x86_64-linux";
          modules =
            [ ./machines/installer/configuration.nix ./modules/zfs.nix ];
          format = "install-iso";
        };
      };
    };
}
