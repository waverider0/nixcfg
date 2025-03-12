local function toggle_line_numbers()
        if vim.wo.relativenumber then
                vim.wo.relativenumber = false
                vim.api.nvim_set_hl(0, "LineNr", { bold = true, fg = "white" })
        else
                vim.wo.relativenumber = true
                vim.api.nvim_set_hl(0, "CursorLineNr", { bold = true, fg = "white" })
                vim.api.nvim_set_hl(0, "LineNr", { bold = false, fg = "grey" })
        end
end
vim.keymap.set({"n", "v"}, "<C-l>", toggle_line_numbers, { noremap = true, silent = true })

local function toggle_word_wrap()
        if vim.opt.wrap:get() then
                vim.opt.wrap = false
                print("word wrap disabled")
        else
                vim.opt.wrap = true
                print("word wrap enabled")
        end
end
vim.api.nvim_create_user_command('WW', toggle_word_wrap, {})
vim.cmd('cnoreabbrev ww WW')
