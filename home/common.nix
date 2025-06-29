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
            vim.opt.expandtab = true
            vim.opt.tabstop = 4
            vim.opt.shiftwidth = 4

            vim.opt.autoindent = false
            vim.opt.smartindent = false
            vim.opt.cindent = false
            vim.cmd("filetype indent off")
            vim.cmd("autocmd FileType * setlocal formatoptions-=cro") -- disable automatic commenting on newline

            vim.opt.ignorecase = true
            vim.opt.smartcase = true

            vim.keymap.set("i", "<C-c>", "<Esc>")
            vim.keymap.set("n", "<C-e>", "<nop>")
            vim.keymap.set("n", "Q", "<nop>")

            vim.opt.clipboard = "unnamedplus"
            vim.opt.hlsearch = false
            vim.opt.number = true
            vim.opt.swapfile = false
            vim.opt.wrap = false

            -- toggle word wrap

            local function toggle_wrap()
                if vim.opt.wrap:get() then
                    vim.opt.wrap = false
                    print("word wrap disabled")
                else
                    vim.opt.wrap = true
                    print("word wrap enabled")
                end
            end
            vim.api.nvim_create_user_command('Wrap', toggle_wrap, {})
            vim.cmd('cnoreabbrev ww Wrap')

            -- align to delimiter

            local function align(delim)
                local first, last = vim.fn.line("'<"), vim.fn.line("'>")
                local esc, max, buf = vim.pesc(delim), 0, {}
                for l = first, last do
                    local text = vim.fn.getline(l)
                    local left, right = text:match("^(.-)%s*" .. esc .. "%s*(.-)$")
                    if left then
                        left = left:gsub("%s+$", "")
                        buf[#buf + 1] = { idx = l, left = left, right = right }
                        if #left > max then max = #left end
                    end
                end
                for _, s in ipairs(buf) do
                    local pad = (" "):rep(max - #s.left + 1)
                    vim.fn.setline(s.idx, s.left .. pad .. delim .. " " .. s.right)
                end
            end
            vim.api.nvim_create_user_command('Align', function(o) align(o.args) end, { range = true, nargs = 1 })
            vim.cmd('cnoreabbrev aa Align')
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
