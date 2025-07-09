{ config, ... }:

{
	home.stateVersion = "25.05";
	programs.home-manager.enable = true;

	programs.alacritty.enable = true;

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
			bind \" split-window -v -c "#{pane_current_path}"

			bind -T root l if-shell -F "#{==:#{pane_mode},tree-mode}" "send-keys NUL" "send-keys l"
			bind -T tree Enter switch-client -t "#{session_id}" \; send-keys q
			bind h select-pane -L
			bind j select-pane -D
			bind k select-pane -U
			bind l select-pane -R

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
			zle -N fgr
			bindkey '^G' fgr

			# autostart tmux in interactive top level shell
			if [[ $- == *i* ]] && [[ -z "$TMUX" ]] && command -v tmux >/dev/null; then
				exec tmux
			fi
		'';
	};

	programs.neovim = {
		enable = true;
		extraLuaConfig = ''
			-- GENERAL SETTINGS
			vim.g.mapleader        = " "
			vim.opt.autoindent     = false
			vim.opt.clipboard      = "unnamedplus"
			vim.opt.confirm        = true
			vim.opt.cursorline     = true
			vim.opt.ignorecase     = true
			vim.opt.number         = true
			vim.opt.relativenumber = true
			vim.opt.smartindent    = false
			vim.opt.smartcase      = true
			vim.opt.swapfile       = false
			vim.opt.wrap           = false

			vim.keymap.set("i"           , "<C-c>"     , "<Esc>")
			vim.keymap.set("n"           , "Q"         , "<nop>")
			vim.keymap.set("n"           , "<C-c>"     , function() if vim.v.hlsearch == 1 then vim.cmd("nohlsearch") end end)
			vim.keymap.set("n"           , "<C-e>"     , "<nop>")
			vim.keymap.set({"n","v"}     , "<C-d>"     , "<C-d>zz")
			vim.keymap.set({"n","v"}     , "<C-u>"     , "<C-u>zz")
			vim.keymap.set({"n","v"}     , "<leader>e" , ":Ex<CR>")
			vim.keymap.set({"n","v","i"} , "<C-q>"     , function() vim.cmd(#vim.api.nvim_list_wins() == 1 and "q" or "bd") end)

			vim.cmd("autocmd FileType * setlocal formatoptions-=cro") -- disable automatic commenting on newline
			vim.cmd("autocmd FileType netrw setlocal syntax=netrw")
			vim.cmd("filetype indent off")
			vim.cmd("syntax manual")

			vim.api.nvim_set_hl(0 , "CursorLineNr" , { fg = "#ffffff", bold = true })
			vim.api.nvim_set_hl(0 , "LineNr"       , { fg = "#5f5f5f", bold = false })

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

			vim.cmd("autocmd FileType netrw nnoremap <buffer> <C-l> gt")
			vim.keymap.set({"n","v","i"}, "<C-l>", "<Esc>:tabnext<CR>")
			vim.keymap.set({"n","v","i"}, "<C-h>", "<Esc>:tabprevious<CR>")

			-- FUZZY FILE SEARCH
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

			vim.keymap.set({"n","v","i"}, "<C-t>", pick_file)

			-- FUZZY DIRECTORY SEARCH
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

			vim.keymap.set({"n","v","i"}, "<C-f>", pick_dir)

			-- FUZZY GREP
			local function pick_grep()
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

			vim.keymap.set({"n","v","i"}, "<C-g>", pick_grep)

			-- ALIGN DELIMITERS
			local function nth_top(line, delim, n)
				local len, depth, quote, esc, hits = #delim, 0, nil, false, {}
				local function add_hit(d, pos) (hits[d] or (function() local t={}; hits[d]=t; return t end)())[ # (hits[d] or {}) + 1 ] = pos end
				local i = 1
				while i <= #line do
					local c = line:sub(i,i)
					if quote then
						esc = (c == "\\") and not esc
						if c == quote and not esc then quote, esc = nil, false end
					else
						if line:sub(i, i+len-1) == delim then add_hit(depth, i); i = i + len; goto continue end
						if c == '"' or c == "'" then quote = c
						elseif c == '(' or c == '{' or c == '[' then depth = depth + 1
						elseif c == ')' or c == '}' or c == ']' then depth = depth - 1 end
					end
					::continue::
					i = i + 1
				end
				local min = math.huge for d in pairs(hits) do if d < min then min = d end end
				local h = hits[min]; if not h then return end
				return h[n], min
			end

			local function align_delim(delim)
				local buf, first, last = 0, vim.fn.line("'<") - 1, vim.fn.line("'>")
				local lines = vim.api.nvim_buf_get_lines(buf, first, last, false)
				local changed = false
				for n = 1, 99 do
					local rows, min_depth, width = {}, math.huge, 0
					for i, line in ipairs(lines) do
						local pos, depth = nth_top(line, delim, n)
						if pos then
							rows[#rows + 1] = {i = i, pos = pos, depth = depth}
							if depth < min_depth then min_depth = depth end
							local left = line:sub(1, pos - 1):gsub("%s+$", "")
							if #left > width then width = #left end
						end
					end
					if width == 0 then break end
					for _, row in ipairs(rows) do
						if row.depth == min_depth then
							local line = lines[row.i]
							local left  = line:sub(1, row.pos - 1):gsub("%s+$", "")
							local right = line:sub(row.pos + #delim):gsub("^%s+", "")
							local padded = left .. string.rep(" ", (width - #left) + 1)
							lines[row.i] = padded .. delim .. " " .. right
							changed = true
						end
					end
				end
				if changed then vim.api.nvim_buf_set_lines(buf, first, last, false, lines) end
			end

			vim.api.nvim_create_user_command("AlignDelim", function(o) align_delim(o.fargs[1]) end, {range = true, nargs = 1})
			vim.keymap.set("v", "<leader>ad", ":'<,'>AlignDelim ")

			-- ALIGN ON
			local function align_on(token)
				local buffer, first, last, pattern = 0, vim.fn.line("'<") - 1, vim.fn.line("'>"), vim.pesc(token)
				local lines = vim.api.nvim_buf_get_lines(buffer, first, last, false)

				local baseline = math.huge
				for _, line in ipairs(lines) do
					local anchor = (line:find('{', 1, true) or 0) + 1
					local token_pos = line:find(pattern, anchor, true)
					if token_pos then
						local offset = token_pos - anchor
						if offset < baseline then baseline = offset end
					end
				end
				if baseline == math.huge then return end
				local pad_if_missing = baseline + #token + 1

				for i, line in ipairs(lines) do
					local anchor = (line:find('{', 1, true) or 0) + 1
					local token_pos = line:find(pattern, anchor, true)
					if token_pos then
						lines[i] = line:sub(1, anchor - 1) .. string.rep(" ", baseline) .. token .. line:sub(token_pos + #token)
					else
						local first_token = anchor + (line:sub(anchor):find('%S') or 1) - 1
						lines[i] = line:sub(1, anchor - 1) .. string.rep(" ", pad_if_missing) .. line:sub(first_token)
					end
				end

				vim.api.nvim_buf_set_lines(buffer, first, last, false, lines)
			end

			vim.api.nvim_create_user_command("AlignOn", function(o) align_on(o.fargs[1]) end, { range = true, nargs = 1 })
			vim.keymap.set("v", "<leader>ao", ":'<,'>AlignOn ")

			-- ALIGN AFTER WORD
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
				for _, row in ipairs(rows) do
					local padded = row.left .. string.rep(" ", (max_left - #row.left) + 1)
					vim.fn.setline(row.idx, padded .. row.right)
				end
			end

			vim.api.nvim_create_user_command("AlignAfter", function(o) align_after(o.args) end, { range = true, nargs = "?" })
			vim.keymap.set("v", "<leader>aa", ":'<,'>AlignAfter<Space>")

			-- TOGGLE WORD WRAP
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
			vim.keymap.set({"n","v"}, "<leader>ww", ":Wrap<CR>")

			-- TOGGLE RELATIVE LINE NUMBERS
			local function toggle_relative()
				local rel = not vim.wo.relativenumber
				vim.wo.relativenumber = rel
				vim.api.nvim_set_hl(0, "LineNr"       , { fg = rel and "#5f5f5f" or "#ffffff" , bold = false })
				vim.api.nvim_set_hl(0, "CursorLineNr" , { fg = "#ffffff"                      , bold = true })
			end

			vim.api.nvim_create_user_command("ToggleRelative", toggle_relative, {})
			vim.keymap.set({"n","v"}, "<leader>rl", ":ToggleRelative<CR>")
		'';
	};
}
