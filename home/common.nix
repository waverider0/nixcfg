{ config, ... }:

{
	home.stateVersion = "25.05";
	programs.home-manager.enable = true;

	programs.alacritty = {
		enable = true;
		settings.window.opacity = 0.90;
	};

	programs.git = {
		enable    = true;
		userEmail = "<waverider0@users.noreply.github.com>";
		userName  = "allen";
	};

	programs.neovim = {
		enable = true;
		defaultEditor = true;
	};
	xdg.configFile."nvim" =  {
		source = ./nvim;
		recursive = true;
	};

	programs.tmux = {
		enable = true;
		extraConfig = ''
			unbind C-b
			set -g prefix `
			bind e send-prefix

			bind Enter new-session
			bind c new-window -c "#{pane_current_path}"

			bind q choose-session
			bind w select-pane -U
			bind a select-pane -L
			bind s select-pane -D
			bind d select-pane -R

			bind h resize-pane -L 20
			bind j resize-pane -D 20
			bind k resize-pane -U 20
			bind l resize-pane -R 20

			set -g -w mode-keys vi
			bind -T copy-mode-vi v send-keys -X begin-selection

			set -g base-index 1
			set -g detach-on-destroy off
			set -g history-limit 10000
			set -g set-clipboard on

			set -g status-style bg=colour235,fg=colour250
			set -g -w window-status-current-style fg=colour2,bold
		'';
	};

	programs.zsh = {
		enable = true;
		oh-my-zsh.enable = true;
		initContent = ''
			export CLICOLOR=1
			export PS1=$'%n@%m:%{\e[01;32m%}%~%{\e[0m%}$ '
			export MANPAGER='nvim +Man!'

			alias open='xdg-open'
			alias vi='nvim'

			set -o vi
			setopt EXTENDED_GLOB
			setopt GLOBDOTS
			setopt NULL_GLOB

			fvi() {
				local file
				file=$(find . -type f 2> /dev/null | fzf) && vi "$file"
				zle reset-prompt; zle -R
			}
			zle -N fvi; bindkey '^T' fvi

			fcd() {
				local dir
				dir=$(find . -type d 2> /dev/null | fzf) && cd "$dir"
				zle reset-prompt; zle -R
			}
			zle -N fcd; bindkey '^F' fcd

			fgr() {
				local pick file line
				pick=$(rg --color=always -n --no-heading "" . 2>/dev/null | fzf --ansi --delimiter ':' --nth 3.. --color=hl:bold:red,hl+:bold:red,fg+:white,bg+:235) || return
				IFS=: read -r file line _ <<< "$pick"
				nvim +"$line" "$file"
				zle reset-prompt; zle -R
			}
			zle -N fgr; bindkey '^G' fgr

			# autostart tmux in interactive top level shell
			if [[ $- == *i* ]] && [[ -z "$TMUX" ]] && command -v tmux >/dev/null; then
				exec tmux
			fi
		'';
	};
}
