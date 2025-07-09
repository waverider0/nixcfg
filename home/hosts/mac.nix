{ config, lib, pkgs, ... }:

{
	home.homeDirectory = "/Users/allen";
	home.username      = "allen";
	home.packages      = [ pkgs.age ];

	age = {
		identityPaths = [ ../../secrets/id ];
		secrets = {
			".kdbx.kdbx.age" = {
				file = ../../secrets/.kdbx.kdbx.age;
				path = "/Users/allen/.kdbx.kdbx";
			};
			"github.age" = {
				file = ../../secrets/github.age;
				path = "/Users/allen/.ssh/github";
			};
			"xmr.age" = {
				file = ../../secrets/xmr.age;
				path = "/Users/allen/.ssh/xmr";
			};
		};
	};

	home.file = {
		".ssh/github.pub".source = ../../secrets/github.pub;
		".ssh/xmr.pub".source = ../../secrets/xmr.pub;
	};

	programs.tmux.extraConfig = lib.mkAfter ''
		set-option -g default-shell /bin/zsh
		bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'pbcopy'
	'';

	programs.zsh.initContent = lib.mkAfter ''
		if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
			. '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
		fi
	'';
}
