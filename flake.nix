{
  description = "allen's nix config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-2411.url = "nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-2411, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      pkgs-2411 = nixpkgs-2411.legacyPackages.${system};
    in {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          pkgs-2411 = import nixpkgs-2411 { inherit system; config.allowUnfree = true; };
        };
        modules = [ ./allen/configuration.nix ];
      };
      homeConfigurations = {
        allen = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ allen/home.nix ];
        };
      };
    };
}
