{ config, ... }:

{
    home.stateVersion = "25.05";
    programs.home-manager.enable = true;

    programs.git = {
        enable    = true;
        userEmail = "<waverider0@users.noreply.github.com>";
        userName  = "allen";
    };

    programs.neovim = {
        enable = true;
        extraLuaConfig = ''
            vim.opt.clipboard = "unnamedplus"
            vim.opt.cursorline = true
            vim.opt.hlsearch = false
            vim.opt.number = true
            vim.opt.swapfile = false
            vim.opt.wrap = false
            vim.cmd("autocmd FileType * setlocal formatoptions-=cro") -- disable automatic commenting on newline

            vim.opt.autoindent = false
            vim.opt.smartindent = false
            vim.opt.cindent = false
            vim.cmd("filetype indent off")

            vim.opt.ignorecase = true
            vim.opt.smartcase = true

            vim.opt.expandtab = true
            vim.opt.tabstop = 4
            vim.opt.shiftwidth = 4

            vim.keymap.set("i", "<C-c>", "<Esc>")
            vim.keymap.set("n", "<C-e>", "<nop>")
            vim.keymap.set("n", "Q", "<nop>")

            local function toggle_word_wrap()
                if vim.opt.wrap:get() then
                    vim.opt.wrap = false
                    print("word wrap disabled")
                else
                    vim.opt.wrap = true
                    print("word wrap enabled")
                end
            end
            vim.api.nvim_create_user_command('WW', toggle_word_wrap, {})
            vim.cmd('cnoreabbrev ww WW')
        '';
    };

    programs.tmux = {
        enable = true;
        extraConfig = ''
            unbind C-b
            set -g prefix `
            bind-key e send-prefix
            bind-key Enter new-session

            set-option -g set-clipboard on
            set-option -g history-limit 5000
            set -g base-index 1

            setw -g mode-keys vi
            bind -T copy-mode-vi v send-keys -X begin-selection

            set -g status-style bg=colour235,fg=colour250
            setw -g window-status-current-style fg=colour2,bold
        '';
    };

    programs.zsh = {
        enable = true;
        oh-my-zsh.enable = true;
        initContent = ''
            export CLICOLOR=1
            export PS1=$'%n@%m:%{\e[01;32m%}%~%{\e[0m%}$ '
            export MANPAGER='nvim +Man!'

            set -o vi
            setopt EXTENDED_GLOB
            setopt GLOBDOTS
            setopt NULL_GLOB

            alias code='codium'
            alias vi='nvim'

            fcd() {
                local dir
                dir=$(find . -type d 2> /dev/null | fzf) && cd "$dir"
                zle reset-prompt; zle -R
            }
            zle -N fcd; bindkey '^F' fcd

            fvi() {
                local file
                file=$(find . -type f 2> /dev/null | fzf) && vi "$file"
                zle reset-prompt; zle -R
            }
            zle -N fvi; bindkey '^T' fvi
        '';
    };
}
