vim.g.mapleader     = " "
vim.opt.autoindent  = false
vim.opt.clipboard   = "unnamedplus"
vim.opt.confirm     = true
vim.opt.ignorecase  = true
vim.opt.number      = true
vim.opt.smartindent = false
vim.opt.smartcase   = true
vim.opt.swapfile    = false
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
vim.cmd("autocmd FileType netrw setlocal syntax=netrw")
vim.cmd("filetype indent off")
vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
vim.cmd("syntax manual")
