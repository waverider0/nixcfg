{
	inputs = {
		nixpkgs.url = "nixpkgs/nixos-25.05";
		nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
		home-manager.url = "github:nix-community/home-manager/release-25.05";
		home-manager.inputs.nixpkgs.follows = "nixpkgs";
	};

	outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }: {
		homeConfigurations = {
			"allen@nixpc" = home-manager.lib.homeManagerConfiguration {
				pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };
				modules = [ ./home/common.nix ./home/nixpc.nix ];
				extraSpecialArgs = { pkgs-unstable = import nixpkgs-unstable { system = "x86_64-linux"; config.allowUnfree = true; }; };
			};
		};

		nixosConfigurations = {
			"nixpc" = nixpkgs.lib.nixosSystem {
				system = "x86_64-linux";
				modules = [ ./hosts/nixpc/configuration.nix ];
				specialArgs = { pkgs-unstable = import nixpkgs-unstable { system = "x86_64-linux"; config.allowUnfree = true; }; };
			};
		};
	};
}
