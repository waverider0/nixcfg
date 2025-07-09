{ config, pkgs, ... }:

{
	imports = [
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
		extraGroups = [ "networkmanager" "wheel" "docker" ];
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

		keyd.enable = true;
		keyd.keyboards.default.settings.main.capslock = "overload(control, noop)";
		libinput.touchpad.disableWhileTyping = true;
	};

	programs.gnome-disks.enable = true;
	programs.zsh.enable = true;

	environment.systemPackages = with pkgs; [
		curl
		git
		htop
		lm_sensors
		lsof
		vim
		wget
		wl-clipboard
	];

	hardware.bluetooth.enable = true;

	system.stateVersion = "25.05";
}
