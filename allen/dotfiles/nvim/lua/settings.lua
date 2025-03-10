vim.opt.clipboard = "unnamedplus"
vim.opt.hlsearch = false
vim.opt.wrap = false

vim.opt.cursorline = true
vim.opt.cursorcolumn = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.number = true
vim.wo.relativenumber = true

vim.opt.expandtab = true
vim.opt.tabstop = 8
vim.opt.shiftwidth = 8

vim.cmd("autocmd FileType * setlocal formatoptions-=cro") -- disable automatic commenting on newline
vim.cmd("autocmd FileType html,json,nix setlocal tabstop=4 shiftwidth=4")
