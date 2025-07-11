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

vim.keymap.set({"n","v","i"}, "<C-t>", pick_file)
vim.keymap.set({"n","v","i"}, "<C-g>", pick_grep)
vim.keymap.set({"n","v","i"}, "<C-f>", pick_dir)
