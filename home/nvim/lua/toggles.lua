local function toggle_wrap()
	if vim.opt.wrap:get() then
		vim.opt.wrap = false
		print("word wrap disabled")
	else
		vim.opt.wrap = true
		print("word wrap enabled")
	end
end

local function toggle_relative()
	local rel = not vim.wo.relativenumber
	vim.wo.relativenumber = rel
	vim.api.nvim_set_hl(0, "LineNr"       , { fg = rel and "#5f5f5f" or "#ffffff" , bold = false })
	vim.api.nvim_set_hl(0, "CursorLineNr" , { fg = "#ffffff"                      , bold = true })
end

vim.api.nvim_create_user_command("Wrap", toggle_wrap, {})
vim.keymap.set({"n","v"}, "<leader>ww", ":Wrap<CR>")

vim.api.nvim_create_user_command("ToggleRelative", toggle_relative, {})
vim.keymap.set({"n","v"}, "<leader>rl", ":ToggleRelative<CR>")
