{
  inputs = {
    impermanence = { url = "github:nix-community/impermanence"; };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server = { url = "github:nix-community/nixos-vscode-server"; };
  };

  outputs =
    { self, nixpkgs, nixos-wsl, impermanence, sops-nix, vscode-server }: {
      nixosConfigurations = {
        laptop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
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
    };
}
