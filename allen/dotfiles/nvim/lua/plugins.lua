vim.g.mapleader = " "

-- setup lazy.nvim

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- setup plugins

require("lazy").setup({
    spec = {
        {
            'nvim-telescope/telescope.nvim',
            branch = '0.1.x',
            dependencies = { 'nvim-lua/plenary.nvim' },
        },
        {
            "nvim-treesitter/nvim-treesitter",
            build = ":TSUpdate",
        },

        {
            "rose-pine/neovim",
            name = "rose-pine"
        },
    },
    checker = { enabled = true },
})

-- telescope

require('telescope').setup {
    defaults = {
        mappings = {
            i = {
                ["<C-d>"] = "delete_buffer"
            }
        }
    }
}

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<C-t>', builtin.find_files, {})
vim.keymap.set('n', '<C-b>', builtin.buffers, {})
vim.keymap.set('n', '<leader>g', builtin.live_grep, {})

-- treesitter

local configs = require("nvim-treesitter.configs")

configs.setup({
    auto_install = false,
    ensure_installed = { "asm", "bash", "c", "cpp", "glsl", "lua", "nix", "python" },
    highlight = { enable = true },
    indent = { enable = false },
    sync_install = false,
})

-- colorscheme

vim.opt.background = "dark"
vim.cmd('colorscheme rose-pine')
