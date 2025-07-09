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
			"allen@mac" = home-manager.lib.homeManagerConfiguration {
				pkgs = import nixpkgs { system = "aarch64-darwin"; config.allowUnfree = true; };
				modules = [ ./home/common.nix ./home/hosts/mac.nix agenix.homeManagerModules.default ];
			};
			"allen@nixpc" = home-manager.lib.homeManagerConfiguration {
				pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };
				modules = [ ./home/common.nix ./home/hosts/nixpc.nix agenix.homeManagerModules.default ];
			};
			"user@xmr" = home-manager.lib.homeManagerConfiguration {
				pkgs = import nixpkgs { system = "x86_64-linux"; };
				modules = [ ./home/common.nix ./home/hosts/xmr.nix ];
			};
		};

		nixosConfigurations = {
			"nixpc" = nixpkgs.lib.nixosSystem {
				system = "x86_64-linux";
				modules = [ ./hosts/nixpc/configuration.nix agenix.nixosModules.default ];
			};
			"xmr" = nixpkgs.lib.nixosSystem {
				system = "x86_64-linux";
				modules = [ ./hosts/xmr/configuration.nix ];
			};
		};
	};
}
