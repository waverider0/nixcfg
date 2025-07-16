{ config, pkgs, ... }:

{
	imports = [
		../common.nix
		./hardware-configuration.nix
	];

	nixpkgs.config.allowUnfree = false;
	nix.settings.experimental-features = [ "nix-command" "flakes" ];

	age = {
		identityPaths = [ ../../secrets/id ];
		secrets."wg_server" = {
			file  = ../../secrets/wg_server.age;
			owner = "root";
			group = "root";
			mode  = "0600";
		};
	};

	boot = {
		loader.systemd-boot.enable          = true;
		loader.efi.canTouchEfiVariables     = true;
		kernel.sysctl."net.ipv4.ip_forward" = "1";
	};

	networking = {
		hostName = "vpn";

		nat.enable             = true;
		nat.externalInterface  = "eth0";
		nat.internalInterfaces = [ "wg0" ];

		firewall.allowedUDPPorts = [ 51820 ];
		firewall.interfaces.wg0.allowedTCPPorts = [ 22 ];

		wireguard.enable = true;
		wireguard.interfaces.wg0 = {
			ips            = [ "10.100.0.1/24" ];
			listenPort     = 51820;
			privateKeyFile = config.age.secrets.wg_server.path;
			peers = [
				{ publicKey = "{laptop public key}"; allowedIPs = [ "10.100.0.2/32" ]; }
				{ publicKey = "{phone public key}"; allowedIPs = [ "10.100.0.3/32" ]; }
			];
		};
	};

	systemd.services."wireguard-wg0".serviceConfig = {
		NoNewPrivileges         = true;
		PrivateTmp              = true;
		PrivateDevices          = true;
		ProtectHome             = "tmpfs";
		ProtectSystem           = "strict";
		ProtectKernelModules    = true;
		ProtectKernelTunables   = true;
		ProtectControlGroups    = true;
		RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
		SystemCallArchitectures = "native";
	};

	services = {
		resolved.enable = true;

		openssh = {
			enable   = true;
			ports    = [ 22 ];
			hostKeys = [{ path = "/etc/secrets/initrd/ssh_host_ed25519_key"; type = "ed25519"; }];
		};
	};

	environment.systemPackages = with pkgs; [
		wl-clipboard
	];

	users.defaultUserShell = pkgs.zsh;
	users.users.user = {
		isNormalUser = true;
		description  = "user";
		extraGroups  = [ "networkmanager" "wheel" ];
	};

	system.stateVersion = "24.11";
}
