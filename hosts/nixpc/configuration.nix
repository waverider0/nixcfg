{ config, pkgs, ... }:

{
	imports = [
		../common.nix
		./hardware-configuration.nix
		./virtualisation.nix
		./vpn.nix
	];

	nixpkgs.config.allowUnfree = true;
	nix.settings.experimental-features = [ "nix-command" "flakes" ];

	users.defaultUserShell = pkgs.zsh;
	users.users.allen = {
		isNormalUser = true;
		description = "allen";
		extraGroups = [ "networkmanager" "wheel" ];
	};

	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	networking.hostName = "nixos";
	networking.networkmanager.enable = true;

	time.timeZone = "America/New_York";
	i18n.defaultLocale = "en_US.UTF-8";
	i18n.extraLocaleSettings = {
		LC_ADDRESS        = "en_US.UTF-8";
		LC_IDENTIFICATION = "en_US.UTF-8";
		LC_MEASUREMENT    = "en_US.UTF-8";
		LC_MONETARY       = "en_US.UTF-8";
		LC_NAME           = "en_US.UTF-8";
		LC_NUMERIC        = "en_US.UTF-8";
		LC_PAPER          = "en_US.UTF-8";
		LC_TELEPHONE      = "en_US.UTF-8";
		LC_TIME           = "en_US.UTF-8";
	};

	security.rtkit.enable = true;

	services = {
		displayManager.sddm.enable = true;
		desktopManager.plasma6.enable = true;

		xserver = {
			enable      = false;
			xkb.layout  = "us";
			xkb.variant = "";
		};

		pipewire = {
			enable            = true;
			alsa.enable       = true;
			alsa.support32Bit = true;
			pulse.enable      = true;
		};

		keyd = {
			enable = true;
			keyboards.default.settings.main = {
				capslock = "overload(control, noop)";
				delete = "grave";
				insert = "grave";
			};
		};
	};

	programs.gnome-disks.enable = true;
	programs.zsh.enable = true;

	environment = {
		systemPackages = with pkgs; [
			lm_sensors
			lsof
			man-pages
			man-pages-posix
			wl-clipboard
		];
		plasma6.excludePackages = with pkgs.kdePackages; [
			kate
			konsole
			elisa
		];
	};

	hardware.bluetooth.enable = true;

	system.stateVersion = "25.05";
}
