vim.opt.clipboard = "unnamedplus"
vim.opt.cursorline = true
vim.opt.hlsearch = false
vim.opt.swapfile = false
vim.opt.wrap = false
vim.cmd("autocmd FileType * setlocal formatoptions-=cro") -- disable automatic commenting on newline

vim.opt.autoindent = false
vim.opt.smartindent = false
vim.opt.cindent = false
vim.cmd("filetype indent off")

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.number = true
vim.wo.relativenumber = true
vim.api.nvim_set_hl(0, "CursorLineNr", { bold = true, fg = "white" })
vim.api.nvim_set_hl(0, "LineNr", { bold = false, fg = "grey" })

vim.opt.expandtab = true
vim.opt.tabstop = 8
vim.opt.shiftwidth = 8
vim.cmd("autocmd FileType html,json,lua,nix setlocal tabstop=4 shiftwidth=4")
