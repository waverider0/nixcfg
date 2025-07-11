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
