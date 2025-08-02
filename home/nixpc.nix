{ config, lib, pkgs, ... }:

{
	home.username = "allen";
	home.homeDirectory = "/home/allen";

	programs.tmux.extraConfig = lib.mkAfter ''
		set-option -g default-shell "${pkgs.zsh}/bin/zsh"
		bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'wl-copy'
	'';

	qt.kde.settings = {
		kdeglobals.General = {
			TerminalApplication = "alacritty";
			TerminalService = "alacritty.desktop";
		};
		kglobalshortcutsrc = {
			kwin."Window Maximize" = "Meta+Return,Meta+PgUp,Maximize Window";
			kwin."Window Minimize" = "Meta+M,Meta+PgUp,Minimize Window";
			services."Alacritty.desktop"._k_friendly_name = "Alacritty";
			services."Alacritty.desktop"._launch = "Meta+Q";
		};
	};

	home.packages = with pkgs; [
		brave
		discord
		ffmpeg
		fzf
		keepassxc
		mpv
		obs-studio
		(python313.withPackages (ps: [ ps.cryptography ]))
		qbittorrent
		ripgrep
		signal-desktop
		spotdl
		spotify
		wireshark
		yt-dlp
	];
}
