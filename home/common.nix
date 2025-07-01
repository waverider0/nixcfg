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
            vim.g.mapleader        = " "
            vim.opt.autoindent     = false
            vim.opt.clipboard      = "unnamedplus"
            vim.opt.cindent        = false
            vim.opt.cursorline     = true
            vim.opt.expandtab      = true
            vim.opt.hlsearch       = false
            vim.opt.ignorecase     = true
            vim.opt.number         = true
            vim.opt.relativenumber = true
            vim.opt.shiftwidth     = 4
            vim.opt.smartindent    = false
            vim.opt.smartcase      = true
            vim.opt.swapfile       = false
            vim.opt.tabstop        = 4
            vim.opt.wrap           = false

            vim.cmd("filetype indent off")
            vim.cmd("autocmd FileType * setlocal formatoptions-=cro") -- disable automatic commenting on newline

            vim.keymap.set("i"       , "<C-c>"      , "<Esc>")
            vim.keymap.set("n"       , "<C-e>"      , "<nop>")
            vim.keymap.set("n"       , "Q"          , "<nop>")
            vim.keymap.set("n"       , "<leader>ex" , ":Ex<CR>")
            vim.keymap.set("n"       , "<leader>q"  , ":q<CR>")
            vim.keymap.set("n"       , "<leader>wq" , ":wq<CR>")
            vim.keymap.set({"n","v"} , "<C-d>"      , "<C-d>zz")
            vim.keymap.set({"n","v"} , "<C-u>"      , "<C-u>zz")

            vim.api.nvim_set_hl(0, "LineNr"       , { fg = "#5f5f5f", bold = false })
            vim.api.nvim_set_hl(0, "CursorLineNr" , { fg = "#ffffff", bold = true })

            -- tabs

            vim.opt.showtabline = 2
            local fn = vim.fn
            function _G.SimpleTabLine()
                local t, cur = {}, fn.tabpagenr()
                for i = 1, fn.tabpagenr("$") do
                    local buf = fn.tabpagebuflist(i)[fn.tabpagewinnr(i)]
                    local name
                    if fn.getbufvar(buf, "&filetype") == "netrw" then
                        name = fn.fnamemodify(fn.getbufvar(buf, "netrw_curdir"), ":t") .. "/"
                    else
                        local path   = fn.fnamemodify(fn.bufname(buf), ":p")
                        local parent = fn.fnamemodify(path, ":h:t")
                        local file   = fn.fnamemodify(path, ":t")
                        name = (parent ~= "" and parent ~= "." and parent .. "/" or "") .. file
                    end
                    if name == "" then name = "[No Name]" end
                    t[#t + 1] = (i == cur and "%#TabLineSel#" or "%#TabLine#") .. " " .. i .. ":" .. name .. " "
                end
                return table.concat(t)
            end
            vim.opt.tabline = "%!v:lua.SimpleTabLine()"
            vim.cmd("autocmd FileType netrw nnoremap <buffer> <C-l> gt")
            vim.keymap.set("n", "<C-l>", "gt", {silent = true, noremap = true})
            vim.keymap.set("n", "<C-h>", "gT", {silent = true, noremap = true})

            -- fuzzy file search

            local function pick_file()
                local tmp = vim.fn.tempname()
                vim.cmd("botright 25new | startinsert")
                local win = vim.api.nvim_get_current_win()
                vim.fn.termopen({ "bash","-c", "find . -type f 2>/dev/null | fzf --bind=ctrl-n:down,ctrl-p:up > "..vim.fn.shellescape(tmp) }, {
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

            -- fuzzy directory search

            local function pick_dir()
                local tmp = vim.fn.tempname()
                vim.cmd("botright 25new | startinsert")
                local win = vim.api.nvim_get_current_win()
                vim.fn.termopen({ "bash","-c","find . -type d -not -path '*/\\.git/*' 2>/dev/null | fzf --bind=ctrl-n:down,ctrl-p:up > "..vim.fn.shellescape(tmp) }, {
                    on_exit = function()
                        local sel = (vim.fn.readfile(tmp)[1] or "") ; vim.fn.delete(tmp)
                        vim.schedule(function()
                            pcall(vim.api.nvim_win_close, win, true)
                            if sel == "" then return end
                            local dir = vim.fn.fnamemodify(sel, ":p")
                            for t = 1, vim.fn.tabpagenr("$") do
                                local b = vim.fn.tabpagebuflist(t)[vim.fn.tabpagewinnr(t)]
                                if vim.fn.getbufvar(b, "&filetype") == "netrw" and vim.fn.fnamemodify(vim.fn.getbufvar(b, "netrw_curdir"), ":p") == dir then vim.cmd(t.."tabnext") ; return end
                            end
                            vim.cmd("tabnew"..vim.fn.fnameescape(dir))
                        end)
                    end}
                )
            end
            vim.keymap.set("n", "<C-F>", pick_dir, { silent = true, noremap = true })

            -- align after word

            local function align_after(n)
                n = tonumber(n) or 1
                local rows, max_left = {}, 0
                local first, last = vim.fn.line("'<"), vim.fn.line("'>")
                for line = first, last do
                    local text, pos, count = vim.fn.getline(line), 1, 0
                    repeat
                        local start, stop = text:find("%S+", pos)
                        if not start then break end
                        count, pos = count + 1, stop + 1
                    until count == n
                    if count == n then
                        local left  = text:sub(1, pos - 1):gsub("%s+$", "")
                        local right = text:sub(pos):gsub("^%s+", "")
                        rows[#rows + 1] = { idx = line, left = left, right = right }
                        if #left > max_left then max_left = #left end
                    end
                end
                local fmt = "%-" .. (max_left + 1) .. "s%s"
                for _, row in ipairs(rows) do vim.fn.setline(row.idx, fmt:format(row.left, row.right)) end
            end
            vim.api.nvim_create_user_command("AlignAfter", function(o) align_after(o.args) end, { range = true, nargs = "?" })
            vim.keymap.set("v", "<leader>aa", ":'<,'>AlignAfter<Space>")

            -- align delimiter

            local function align_delim(delim, n)
                n = tonumber(n) or 1
                local esc, rows, max_left = vim.pesc(delim), {}, 0
                local first, last = vim.fn.line("'<"), vim.fn.line("'>")
                for line = first, last do
                    local text, pos, count = vim.fn.getline(line), 1, 0
                    while true do
                        local start, stop = text:find("%s*" .. esc .. "%s*", pos)
                        if not start then break end
                        count, pos = count + 1, stop + 1
                        if count == n then
                            local left  = text:sub(1, start - 1):gsub("%s+$", "")
                            local right = text:sub(stop + 1):gsub("^%s+", "")
                            rows[#rows + 1] = { line, left, right }
                            if #left > max_left then max_left = #left end
                            break
                        end
                    end
                end
                local fmt = "%-" .. (max_left + 1) .. "s%s %s"
                for _, r in ipairs(rows) do vim.fn.setline(r[1], fmt:format(r[2], delim, r[3])) end
            end
            vim.api.nvim_create_user_command("AlignDelim", function(o) align_delim(o.fargs[1], o.fargs[2]) end, { range = true, nargs = "+" })
            vim.keymap.set("v", "<leader>ad", ":'<,'>AlignDelim<Space>")

            -- toggle relative line numbers

            local function toggle_relative()
                local rel = not vim.wo.relativenumber
                vim.wo.relativenumber = rel
                vim.api.nvim_set_hl(0, "LineNr"       , { fg = rel and "#5f5f5f" or "#ffffff" , bold = false })
                vim.api.nvim_set_hl(0, "CursorLineNr" , { fg = "#ffffff"                      , bold = true })
            end
            vim.api.nvim_create_user_command("ToggleRelative", toggle_relative, {})
            vim.keymap.set("n", "<leader>rl", ":ToggleRelative<CR>")

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
            vim.keymap.set("n", "<leader>ww", ":Wrap<CR>")
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
        '';
    };
}
