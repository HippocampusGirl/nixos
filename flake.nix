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
    nixpkgs.url = "github:nixos/nixpkgs/release-23.05";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = { url = "github:nix-community/nixos-vscode-server"; };
  };
  outputs = { self, nixpkgs, home-manager, impermanence, nixos-generators
    , nixos-wsl, sops-nix, vscode-server }: {
      nixosModules = {
        default = { config, ... }: {
          imports = [
            ./modules/command-not-found.nix
            ./modules/direnv.nix
            ./modules/git.nix
            ./modules/htop.nix
            ./modules/i18n.nix
            ./modules/less.nix
            ./modules/neovim.nix
            ./modules/singularity.nix
            ./modules/tailscale.nix
            ./modules/tmux.nix
            ./modules/zsh.nix
          ];
        };
        home = { config, ... }: {
          imports = [
            self.nixosModules.default
            ./home/configuration.nix
            impermanence.nixosModules.impermanence
            sops-nix.nixosModules.sops
          ];
        };
        laptop = { config, ... }: {
          imports = [
            self.nixosModules.default
            ./laptop/configuration.nix
            home-manager.nixosModules.home-manager
            nixos-wsl.nixosModules.wsl
            sops-nix.nixosModules.sops
            vscode-server.nixosModules.default
          ];
        };
        server = { config, ... }: {
          imports = [
            self.nixosModules.default
            ./server/configuration.nix
            impermanence.nixosModules.impermanence
            sops-nix.nixosModules.sops
          ];
        };
      };
      nixosConfigurations = {
        home = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ self.nixosModules.home ];
        };
        laptop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ self.nixosModules.laptop ];
        };
        server = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ self.nixosModules.server ];
        };
      };
      packages.x86_64-linux = {
        installer = nixos-generators.nixosGenerate {
          system = "x86_64-linux";
          modules = [ ./installer/configuration.nix ];
          format = "install-iso";
        };
      };
    };
}
