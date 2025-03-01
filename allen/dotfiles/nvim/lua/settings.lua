vim.opt.clipboard = "unnamedplus"
vim.opt.hlsearch = false
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.number = true
vim.wo.relativenumber = true

vim.cmd("autocmd FileType * setlocal formatoptions-=cro")
vim.cmd([[
  autocmd BufEnter * setlocal tabstop=8
  autocmd BufEnter * setlocal shiftwidth=8
  autocmd BufEnter * setlocal expandtab
]])

vim.g.zig_fmt_autosave = false
vim.g.zig_fmt_parse_errors = 0
