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
vim.cmd("syntax off")

vim.api.nvim_set_hl(0 , "CursorLineNr" , { fg = "#ffffff", bold = true })
vim.api.nvim_set_hl(0 , "LineNr"       , { fg = "#5f5f5f", bold = false })
