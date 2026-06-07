-- :lua require("export_keymaps").export_markdown()

local M = {}

local modes = {
	{ short = "n", name = "Normal" },
	{ short = "i", name = "Insert" },
	{ short = "v", name = "Visual" },
	{ short = "x", name = "Visual Block" },
	{ short = "s", name = "Select" },
	{ short = "o", name = "Operator-pending" },
	{ short = "c", name = "Command" },
	{ short = "t", name = "Terminal" },
}

local builtins = {
	n = {
		{ lhs = "h", desc = "Move left" },
		{ lhs = "j", desc = "Move down" },
		{ lhs = "k", desc = "Move up" },
		{ lhs = "l", desc = "Move right" },
		{ lhs = "w", desc = "Next word" },
		{ lhs = "b", desc = "Previous word" },
		{ lhs = "e", desc = "End of word" },
		{ lhs = "0", desc = "Start of line" },
		{ lhs = "^", desc = "First non-blank of line" },
		{ lhs = "$", desc = "End of line" },
		{ lhs = "gg", desc = "Go to first line" },
		{ lhs = "G", desc = "Go to last line" },
		{ lhs = "%", desc = "Jump to matching pair" },
		{ lhs = "/", desc = "Search forward" },
		{ lhs = "?", desc = "Search backward" },
		{ lhs = "n", desc = "Next search result" },
		{ lhs = "N", desc = "Previous search result" },
		{ lhs = "dd", desc = "Delete line" },
		{ lhs = "yy", desc = "Yank line" },
		{ lhs = "p", desc = "Paste after" },
		{ lhs = "P", desc = "Paste before" },
		{ lhs = "u", desc = "Undo" },
		{ lhs = "<C-r>", desc = "Redo" },
		{ lhs = "x", desc = "Delete character under cursor" },
		{ lhs = "o", desc = "Open line below" },
		{ lhs = "O", desc = "Open line above" },
	},
	i = {
		{ lhs = "<Esc>", desc = "Leave insert mode" },
		{ lhs = "<BS>", desc = "Delete previous character" },
		{ lhs = "<C-w>", desc = "Delete previous word" },
		{ lhs = "<C-u>", desc = "Delete to start of line" },
		{ lhs = "<Left>", desc = "Move left" },
		{ lhs = "<Right>", desc = "Move right" },
		{ lhs = "<Up>", desc = "Move up" },
		{ lhs = "<Down>", desc = "Move down" },
	},
	v = {
		{ lhs = "y", desc = "Yank selection" },
		{ lhs = "d", desc = "Delete selection" },
		{ lhs = "c", desc = "Change selection" },
		{ lhs = "<", desc = "Indent left" },
		{ lhs = ">", desc = "Indent right" },
		{ lhs = "=", desc = "Format selection" },
	},
	x = {
		{ lhs = "y", desc = "Yank block selection" },
		{ lhs = "d", desc = "Delete block selection" },
		{ lhs = "c", desc = "Change block selection" },
		{ lhs = "I", desc = "Insert at start of block" },
		{ lhs = "A", desc = "Append at end of block" },
	},
	o = {
		{ lhs = "iw", desc = "Inner word" },
		{ lhs = "aw", desc = "A word" },
		{ lhs = "i(", desc = "Inner parentheses" },
		{ lhs = "a(", desc = "Around parentheses" },
		{ lhs = "i{", desc = "Inner braces" },
		{ lhs = "a{", desc = "Around braces" },
		{ lhs = 'i"', desc = "Inside double quotes" },
		{ lhs = 'a"', desc = "Around double quotes" },
	},
	c = {
		{ lhs = "<C-b>", desc = "Move left in command-line" },
		{ lhs = "<C-f>", desc = "Move right in command-line" },
		{ lhs = "<C-a>", desc = "Start of command-line" },
		{ lhs = "<C-e>", desc = "End of command-line" },
	},
	t = {
		{ lhs = "<C-\\><C-n>", desc = "Exit terminal mode" },
	},
}

local function esc(s)
	s = tostring(s or "")
	s = s:gsub("\\", "\\\\")
	s = s:gsub("|", "\\|")
	s = s:gsub("\n", "\\n")
	s = s:gsub("\r", "\\r")
	return s
end

local function mode_name(short)
	for _, m in ipairs(modes) do
		if m.short == short then
			return m.name
		end
	end
	return short
end

local function get_leader()
	if vim.g.mapleader == nil or vim.g.mapleader == "" then
		return "\\"
	end
	return vim.g.mapleader
end

local function get_localleader()
	if vim.g.maplocalleader == nil or vim.g.maplocalleader == "" then
		return "\\"
	end
	return vim.g.maplocalleader
end

local function render_key(lhs)
	lhs = lhs or ""

	local leader = get_leader()
	local localleader = get_localleader()

	if localleader ~= "" then
		lhs = lhs:gsub(vim.pesc(localleader), "<localleader>")
	end
	if leader ~= "" then
		lhs = lhs:gsub(vim.pesc(leader), "<leader>")
	end

	if lhs == " " then
		lhs = "<Space>"
	end

	return lhs
end

local function is_noise_map(m)
	local lhs = m.lhs or ""
	local rhs = m.rhs or ""
	local desc = m.desc or ""

	if lhs:match("^<Plug>") then
		return true
	end
	if rhs:match("<Plug>") then
		return true
	end
	if lhs:match("^<SNR>") or rhs:match("^<SNR>") then
		return true
	end
	if desc:match("^blink%.cmp") then
		return true
	end
	return false
end

local function action_of(m)
	if m.rhs and m.rhs ~= "" then
		return m.rhs
	end
	if m.desc and m.desc ~= "" then
		return "[Lua callback]"
	end
	return ""
end

local function short_bufname(name)
	if not name or name == "" then
		return "[No Name]"
	end

	local cwd = vim.loop.cwd()
	if cwd and name:sub(1, #cwd) == cwd then
		local rel = name:sub(#cwd + 2)
		if rel ~= "" then
			return rel
		end
	end

	return vim.fn.fnamemodify(name, ":~")
end

local function get_buffer_info(bufnr)
	local name = vim.api.nvim_buf_get_name(bufnr)
	local filetype = vim.bo[bufnr].filetype or ""
	return {
		number = tostring(bufnr),
		name = short_bufname(name),
		filetype = filetype ~= "" and filetype or "-",
	}
end

local function normalize(mode, maptype, bufnr, m)
	local buffer = ""
	local buffer_name = ""
	local filetype = ""

	if bufnr then
		local info = get_buffer_info(bufnr)
		buffer = info.number
		buffer_name = info.name
		filetype = info.filetype
	end

	return {
		mode = mode,
		mode_name = mode_name(mode),
		lhs = render_key(m.lhs or ""),
		type = maptype,
		action = action_of(m),
		desc = m.desc or "",
		buffer = buffer,
		buffer_name = buffer_name,
		filetype = filetype,
	}
end

local function collect_entries()
	local items = {}

	for _, m in ipairs(modes) do
		local mode = m.short

		for _, b in ipairs(builtins[mode] or {}) do
			table.insert(items, {
				mode = mode,
				mode_name = mode_name(mode),
				lhs = render_key(b.lhs),
				type = "builtin",
				action = "",
				desc = b.desc or "",
				buffer = "",
				buffer_name = "",
				filetype = "",
			})
		end

		for _, km in ipairs(vim.api.nvim_get_keymap(mode)) do
			if not is_noise_map(km) then
				table.insert(items, normalize(mode, "global", nil, km))
			end
		end

		local seen = {}
		for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
			if vim.api.nvim_buf_is_loaded(bufnr) then
				for _, km in ipairs(vim.api.nvim_buf_get_keymap(bufnr, mode)) do
					if not is_noise_map(km) then
						local item = normalize(mode, "buffer", bufnr, km)
						local key = table.concat({
							item.mode,
							item.lhs,
							item.type,
							item.action,
							item.desc,
							item.buffer,
							item.buffer_name,
							item.filetype,
						}, "||")

						if not seen[key] then
							seen[key] = true
							table.insert(items, item)
						end
					end
				end
			end
		end
	end

	table.sort(items, function(a, b)
		if a.mode ~= b.mode then
			return a.mode < b.mode
		end
		if a.lhs ~= b.lhs then
			return a.lhs < b.lhs
		end
		if a.type ~= b.type then
			return a.type < b.type
		end
		if (a.buffer_name or "") ~= (b.buffer_name or "") then
			return (a.buffer_name or "") < (b.buffer_name or "")
		end
		return (a.buffer or "") < (b.buffer or "")
	end)

	return items
end

local function add_conflicts(items)
	local counts = {}

	for _, item in ipairs(items) do
		local key = item.mode .. "||" .. item.lhs
		counts[key] = (counts[key] or 0) + 1
	end

	for _, item in ipairs(items) do
		local key = item.mode .. "||" .. item.lhs
		item.conflict = counts[key] > 1 and "yes" or ""
		item.notes = ""

		if item.conflict == "yes" then
			if item.type == "buffer" then
				item.notes = "Shared key in this mode; buffer-local may override others"
			elseif item.type == "global" then
				item.notes = "Shared key in this mode"
			elseif item.type == "builtin" then
				item.notes = "Builtin key is shadowed by mapping"
			end
		end
	end
end

function M.export_markdown()
	local items = collect_entries()
	add_conflicts(items)

	local lines = {
		"# Neovim Mapping Report",
		"",
		"Legend:",
		"- **Keys (LHS)** = what you press",
		"- **Action (RHS)** = what runs",
		"- **Type** = builtin, global, or buffer",
		"",
	}

	for _, m in ipairs(modes) do
		local mode_items = {}
		for _, item in ipairs(items) do
			if item.mode == m.short then
				table.insert(mode_items, item)
			end
		end

		table.insert(lines, "## " .. m.name .. " mode")
		table.insert(lines, "")
		table.insert(
			lines,
			"| Mode | Keys | Type | Action | Description | Buffer | Buffer Name | Filetype | Conflict | Notes |"
		)
		table.insert(lines, "|---|---|---|---|---|---|---|---|---|---|")

		for _, item in ipairs(mode_items) do
			table.insert(
				lines,
				string.format(
					"| `%s` | `%s` | %s | `%s` | %s | %s | %s | %s | %s | %s |",
					esc(item.mode_name),
					esc(item.lhs),
					esc(item.type),
					esc(item.action),
					esc(item.desc),
					esc(item.buffer),
					esc(item.buffer_name),
					esc(item.filetype),
					esc(item.conflict),
					esc(item.notes)
				)
			)
		end

		if #mode_items == 0 then
			table.insert(lines, "| | | | | | | | | | |")
		end

		table.insert(lines, "")
	end

	vim.fn.writefile(lines, vim.fn.expand("~/keymaps_report.md"))
	print("Wrote ~/keymaps_report.md")
end

return M
