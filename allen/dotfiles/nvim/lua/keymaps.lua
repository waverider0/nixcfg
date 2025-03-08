vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set("n", "<C-e>", "<nop>")
vim.keymap.set("n", "Q", "<nop>")

local function toggle_line_numbers()
        if vim.wo.relativenumber then
                vim.wo.relativenumber = false
        else
                vim.wo.relativenumber = true
        end
end
vim.keymap.set({"n", "v"}, "<C-l>", toggle_line_numbers, { noremap = true, silent = true })
