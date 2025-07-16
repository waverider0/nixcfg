{ pkgs, ... }:

{
	environment.systemPackages = with pkgs; [
		curl
		git
		htop
		vim
		wget
	];
}
