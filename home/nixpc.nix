{ config, lib, pkgs, ... }:

{
	home.username      = "allen";
	home.homeDirectory = "/home/allen";

	home.file = {
		".ssh/config".source = ../secrets/ssh_config;
		".ssh/github.pub".source = ../secrets/github.pub;
	};

	age = {
		identityPaths = [ ../secrets/id ];
		secrets = {
			".kdbx.kdbx.age" = {
				file = ../secrets/.kdbx.kdbx.age;
				path = "/home/allen/.kdbx.kdbx";
			};
			"github.age" = {
				file = ../secrets/github.age;
				path = "/home/allen/.ssh/github";
			};
		};
	};

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
			"services/Alacritty.desktop"._k_friendly_name = "Alacritty";
			"services/Alacritty.desktop"._launch = "Meta+Q,none,Launch Alacritty";
		};
	};

	home.packages = with pkgs; [
		age
		brave
		discord
		ffmpeg
		fzf
		gimp
		kdePackages.kdenlive
		keepassxc
		obs-studio
		opentofu
		qbittorrent
		ripgrep
		signal-desktop
		spotdl
		spotify
		vlc
		wireshark
		xournalpp
		yt-dlp
	];
}
