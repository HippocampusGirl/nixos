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
      nixosConfigurations = {
        laptop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            home-manager.nixosModules.home-manager
            nixos-wsl.nixosModules.wsl
            sops-nix.nixosModules.sops
            vscode-server.nixosModules.default
            ./laptop/configuration.nix
          ];
        };
        server = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            impermanence.nixosModules.impermanence
            sops-nix.nixosModules.sops
            ./server/configuration.nix
          ];
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
