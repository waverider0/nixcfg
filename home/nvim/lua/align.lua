-- @NOTE: use very sparingly otherwise will create editing friction (esp for other maintainers)

local function align(n)
	n = tonumber(n) or 1
	local rows, max_left = {}, 0
	local first, last = vim.fn.line("'<"), vim.fn.line("'>")
	for line = first, last do
		local text, pos, count = vim.fn.getline(line), 1, 0
		repeat
			local start, stop = text:find("%S+", pos)
			if not start then break end
			count, pos = count + 1, stop + 1
		until count == n
		if count == n then
			local left  = text:sub(1, pos - 1):gsub("%s+$", "")
			local right = text:sub(pos):gsub("^%s+", "")
			rows[#rows + 1] = { idx = line, left = left, right = right }
			if #left > max_left then max_left = #left end
		end
	end
	for _, row in ipairs(rows) do
		local padded = row.left .. string.rep(" ", (max_left - #row.left) + 1)
		vim.fn.setline(row.idx, padded .. row.right)
	end
end

vim.api.nvim_create_user_command("A", function(o) align(o.args) end, { range = true, nargs = "?" })
