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

            -- tabs

            vim.o.showtabline = 2
            local fn = vim.fn
            function _G.SimpleTabLine()
                local t, cur = {}, fn.tabpagenr()
                for i = 1, fn.tabpagenr("$") do
                    local name = fn.fnamemodify(fn.bufname(fn.tabpagebuflist(i)[fn.tabpagewinnr(i)]), ":t")
                    t[#t + 1] = (i == cur and "%#TabLineSel#" or "%#TabLine#") .. " " .. i .. ":" .. (name ~= "" and name or "[No Name]") .. " "
                end
                return table.concat(t)
            end
            vim.o.tabline = "%!v:lua.SimpleTabLine()"
            vim.keymap.set("n", "<C-l>",  "gt", {silent = true, noremap = true})
            vim.keymap.set("n", "<C-h>","gT", {silent = true, noremap = true})

            -- file search

            local function pick_file()
                local tmp = vim.fn.tempname()
                vim.cmd("botright 25new | startinsert")
                local win = vim.api.nvim_get_current_win()
                vim.fn.termopen({"bash","-c", "find . -type f 2>/dev/null | fzf --bind=ctrl-n:down,ctrl-p:up > "..vim.fn.shellescape(tmp)}, {
                    on_exit = function()
                        local sel = vim.fn.readfile(tmp)[1] or "" ; vim.fn.delete(tmp)
                        vim.schedule(function()
                            pcall(vim.api.nvim_win_close, win, true)
                            if sel ~= "" then vim.cmd("tab drop"..vim.fn.fnameescape(sel)) end
                        end)
                    end
                })
            end
            vim.keymap.set("n", "<C-T>", pick_file, { silent = true, noremap = true })

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
            vim.api.nvim_create_user_command("Align", function(o) align(o.args) end, { range = true, nargs = 1 })
            vim.cmd("cnoreabbrev aa Align")

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
            vim.api.nvim_create_user_command("Wrap", toggle_wrap, {})
            vim.cmd("cnoreabbrev ww Wrap")
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

            alias vi='nvim'
            set -o vi

            setopt EXTENDED_GLOB
            setopt GLOBDOTS
            setopt NULL_GLOB

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
