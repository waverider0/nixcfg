{
	inputs = {
		nixpkgs.url = "nixpkgs/nixos-unstable";
		home-manager = {
			url = "github:nix-community/home-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = { self, nixpkgs, home-manager, ... }: {
		homeConfigurations = {
			"allen@nixpc" = home-manager.lib.homeManagerConfiguration {
				pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };
				modules = [ ./home/common.nix ./home/nixpc.nix ];
			};
		};

		nixosConfigurations = {
			"nixpc" = nixpkgs.lib.nixosSystem {
				system = "x86_64-linux";
				modules = [ ./hosts/nixpc/configuration.nix ];
			};
		};
	};
}
