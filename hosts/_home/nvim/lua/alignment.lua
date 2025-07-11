-- ALIGN DELIMITERS
local function nth_top(line, delim, n)
	local len, depth, quote, esc, hits = #delim, 0, nil, false, {}
	local function add_hit(d, pos) (hits[d] or (function() local t={}; hits[d]=t; return t end)())[ # (hits[d] or {}) + 1 ] = pos end
	local i = 1
	while i <= #line do
		local c = line:sub(i,i)
		if quote then
			esc = (c == "\\") and not esc
			if c == quote and not esc then quote, esc = nil, false end
		else
			if line:sub(i, i+len-1) == delim then add_hit(depth, i); i = i + len; goto continue end
			if c == '"' or c == "'" then quote = c
			elseif c == '(' or c == '{' or c == '[' then depth = depth + 1
			elseif c == ')' or c == '}' or c == ']' then depth = depth - 1 end
		end
		::continue::
		i = i + 1
	end
	local min = math.huge for d in pairs(hits) do if d < min then min = d end end
	local h = hits[min]; if not h then return end
	return h[n], min
end

local function align_delim(delim)
	local buf, first, last = 0, vim.fn.line("'<") - 1, vim.fn.line("'>")
	local lines = vim.api.nvim_buf_get_lines(buf, first, last, false)
	local changed = false
	for n = 1, 99 do
		local rows, min_depth, width = {}, math.huge, 0
		for i, line in ipairs(lines) do
			local pos, depth = nth_top(line, delim, n)
			if pos then
				rows[#rows + 1] = {i = i, pos = pos, depth = depth}
				if depth < min_depth then min_depth = depth end
				local left = line:sub(1, pos - 1):gsub("%s+$", "")
				if #left > width then width = #left end
			end
		end
		if width == 0 then break end
		for _, row in ipairs(rows) do
			if row.depth == min_depth then
				local line = lines[row.i]
				local left  = line:sub(1, row.pos - 1):gsub("%s+$", "")
				local right = line:sub(row.pos + #delim):gsub("^%s+", "")
				local padded = left .. string.rep(" ", (width - #left) + 1)
				lines[row.i] = padded .. delim .. " " .. right
				changed = true
			end
		end
	end
	if changed then vim.api.nvim_buf_set_lines(buf, first, last, false, lines) end
end

-- ALIGN ON
local function align_on(token)
	local buffer, first, last, pattern = 0, vim.fn.line("'<") - 1, vim.fn.line("'>"), vim.pesc(token)
	local lines = vim.api.nvim_buf_get_lines(buffer, first, last, false)

	local baseline = math.huge
	for _, line in ipairs(lines) do
		local anchor = (line:find('{', 1, true) or 0) + 1
		local token_pos = line:find(pattern, anchor, true)
		if token_pos then
			local offset = token_pos - anchor
			if offset < baseline then baseline = offset end
		end
	end
	if baseline == math.huge then return end
	local pad_if_missing = baseline + #token + 1

	for i, line in ipairs(lines) do
		local anchor = (line:find('{', 1, true) or 0) + 1
		local token_pos = line:find(pattern, anchor, true)
		if token_pos then
			lines[i] = line:sub(1, anchor - 1) .. string.rep(" ", baseline) .. token .. line:sub(token_pos + #token)
		else
			local first_token = anchor + (line:sub(anchor):find('%S') or 1) - 1
			lines[i] = line:sub(1, anchor - 1) .. string.rep(" ", pad_if_missing) .. line:sub(first_token)
		end
	end

	vim.api.nvim_buf_set_lines(buffer, first, last, false, lines)
end

-- ALIGN AFTER WORD
local function align_after(n)
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

vim.api.nvim_create_user_command("AlignDelim", function(o) align_delim(o.fargs[1]) end, {range = true, nargs = 1})
vim.api.nvim_create_user_command("AlignOn", function(o) align_on(o.fargs[1]) end, { range = true, nargs = 1 })
vim.api.nvim_create_user_command("AlignAfter", function(o) align_after(o.args) end, { range = true, nargs = "?" })
vim.keymap.set("v", "<leader>ad", ":'<,'>AlignDelim ")
vim.keymap.set("v", "<leader>ao", ":'<,'>AlignOn ")
vim.keymap.set("v", "<leader>aa", ":'<,'>AlignAfter ")
