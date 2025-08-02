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

	programs.tmux = {
		enable = true;
		extraConfig = ''
			unbind C-b
			set -g prefix `
			bind e send-prefix

			bind Enter new-session
			bind c new-window -c "#{pane_current_path}"
			bind % split-window -h -c "#{pane_current_path}"

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

	programs.neovim = {
		enable = true;
		defaultEditor = true;
		extraLuaConfig = ''
			vim.g.mapleader     = " "
			vim.opt.autoindent  = false
			vim.opt.clipboard   = "unnamedplus"
			vim.opt.confirm     = true
			vim.opt.expandtab   = false
			vim.opt.ignorecase  = true
			vim.opt.number      = true
			vim.opt.shiftwidth  = 8
			vim.opt.smartcase   = true
			vim.opt.smartindent = false
			vim.opt.smarttab    = true
			vim.opt.softtabstop = 8
			vim.opt.swapfile    = false
			vim.opt.tabstop     = 8
			vim.opt.wrap        = false

			vim.keymap.set("i"       , "<C-c>"     , "<Esc>")
			vim.keymap.set("n"       , "<C-e>"     , "<nop>")
			vim.keymap.set("n"       , "Q"         , "<nop>")
			vim.keymap.set({"n","v"} , "<C-d>"     , "<C-d>zz")
			vim.keymap.set({"n","v"} , "<C-u>"     , "<C-u>zz")
			vim.keymap.set({"n","v"} , "<leader>e" , ":Ex<CR>")
			vim.keymap.set({"n","v"} , "s"         , "<nop>")

			vim.keymap.set("n"           , "<C-c>"      , function() if vim.v.hlsearch == 1 then vim.cmd("nohlsearch") end end)
			vim.keymap.set({"n","v"}     , "<leader>ww" , function() vim.opt.wrap = not vim.opt.wrap:get() end)
			vim.keymap.set({"n","v","i"} , "<C-q>"      , function() vim.cmd(#vim.api.nvim_list_wins() == 1 and "q" or "bd") end)

			vim.cmd("autocmd FileType * setlocal formatoptions-=cro")
			vim.cmd("autocmd FileType * setlocal noexpandtab tabstop=8 shiftwidth=8 softtabstop=8")
			vim.cmd("autocmd FileType netrw setlocal syntax=netrw")
			vim.cmd("filetype indent off")
			vim.cmd("filetype plugin indent off")
			vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
			vim.cmd("syntax manual")

			-- TABS
			vim.opt.showtabline = 2
			vim.opt.tabline = "%!v:lua.SimpleTabLine()"

			function _G.SimpleTabLine()
				local t, cur = {}, vim.fn.tabpagenr()
				for i = 1, vim.fn.tabpagenr("$") do
					local buf = vim.fn.tabpagebuflist(i)[vim.fn.tabpagewinnr(i)]
					local name
					if vim.fn.getbufvar(buf, "&filetype") == "netrw" then
						name = vim.fn.fnamemodify(vim.fn.getbufvar(buf, "netrw_curdir"), ":t") .. "/"
					else
						local path   = vim.fn.fnamemodify(vim.fn.bufname(buf), ":p")
						local parent = vim.fn.fnamemodify(path, ":h:t")
						local file   = vim.fn.fnamemodify(path, ":t")
						name = (parent ~= "" and parent ~= "." and parent .. "/" or "") .. file
					end
					if name == "" then name = "[No Name]" end
					t[#t + 1] = (i == cur and "%#TabLineSel#" or "%#TabLine#") .. " " .. i .. ":" .. name .. " "
				end
				return table.concat(t)
			end

			vim.keymap.set({"n","v"}, "<leader>f", ":tabnew | Ex<CR>")
			vim.keymap.set({"n","v"}, "<leader>t", ":tabnew<CR>")
			vim.keymap.set({"n","v","i"}, "<C-h>", "<Esc>:tabprevious<CR>")
			vim.keymap.set({"n","v","i"}, "<C-l>", "<Esc>:tabnext<CR>")

			vim.cmd("autocmd FileType netrw nnoremap <buffer> <C-l> gt")

			-- FUZZY
			local function grep()
				local tmp = vim.fn.tempname()
				vim.cmd("botright 25new | startinsert")
				local win = vim.api.nvim_get_current_win()
				vim.fn.termopen({
					"bash", "-c",
					"rg --color=always -n --no-heading \"\" . 2>/dev/null | " ..
					"fzf --ansi --delimiter ':' --nth 3.. " ..
					"--color=hl:bold:red,hl+:bold:red,fg+:white > " .. vim.fn.shellescape(tmp)
				}, {
					on_exit = function()
						local sel = (vim.fn.readfile(tmp)[1] or "")
						vim.fn.delete(tmp)
						vim.schedule(function()
							pcall(vim.api.nvim_win_close, win, true)
							if sel == "" then return end
							local file, line = sel:match("^([^:]+):(%d+):")
							line = tonumber(line) or 1
							vim.cmd("tab drop " .. vim.fn.fnameescape(file))
							vim.cmd(string.format("%d", line))
							vim.cmd("normal! zz")
						end)
					end
				})
			end

			local function files()
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

			local function folders()
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
					end
				})
			end

			vim.keymap.set({"n","v","i"}, "<C-g>", grep)
			vim.keymap.set({"n","v","i"}, "<C-t>", files)
			vim.keymap.set({"n","v","i"}, "<C-f>", folders)

			-- ALIGN
			-- @NOTE: use sparingly otherwise creates editing friction
			local function align(n)
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
				for _, row in ipairs(rows) do
					local padded = row.left .. string.rep(" ", (max_left - #row.left) + 1)
					vim.fn.setline(row.idx, padded .. row.right)
				end
			end

			vim.api.nvim_create_user_command("A", function(o) align(o.args) end, { range = true, nargs = "?" })
		'';
	};
}
