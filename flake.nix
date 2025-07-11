{
	inputs = {
		nixpkgs.url = "nixpkgs/nixos-unstable";
		agenix = {
			url = "github:ryantm/agenix";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = { self, nixpkgs, agenix, home-manager, ... }: {
		homeConfigurations = {
			"allen@nixpc" = home-manager.lib.homeManagerConfiguration {
				pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };
				modules = [ ./home/common.nix ./home/nixpc.nix agenix.homeManagerModules.default ];
			};
		};

		nixosConfigurations = {
			"nixpc" = nixpkgs.lib.nixosSystem {
				system = "x86_64-linux";
				modules = [ ./hosts/nixpc/configuration.nix agenix.nixosModules.default ];
			};
		};
	};
}
