-- ============================================================
-- SECTION 3: UI / CORE UX PLUGINS
-- guess-indent, gitsigns, which-key, colorscheme, todo-comments, mini modules
-- ============================================================
do
	-- [[ Installing and Configuring Plugins ]]
	--
	-- To install a plugin simply call `vim.pack.add` with its git url.
	-- This will download the default branch of the plugin, which will usually be `main` or `master`
	-- You can also have more advanced specs, which we will talk about later.
	--
	-- For most plugins its not enough to install them, you also need to call their `.setup()` to start them.
	--
	-- For example, lets say we want to install `guess-indent.nvim` - a plugin for
	-- automatically detecting and setting the indentation.
	--
	-- We first install it from https://github.com/NMAC427/guess-indent.nvim
	-- and then call its `setup()` function to start it with default settings.

	vim.pack.add({ gh("NMAC427/guess-indent.nvim") })
	require("guess-indent").setup({})

	-- Because lua is a real programming language, you can also have some logic to your installation -
	-- like only installing a plugin if a condition is met.
	--
	-- Here we only install `nvim-web-devicons` (which adds pretty icons) if we have a Nerd Font,
	-- since otherwise the icons won't display properly.
	if vim.g.have_nerd_font then
		vim.pack.add({ gh("nvim-tree/nvim-web-devicons") })
	end

	-- Here is a more advanced configuration example that passes options to `gitsigns.nvim`
	--
	-- See `:help gitsigns` to understand what each configuration key does.
	-- Adds git related signs to the gutter, as well as utilities for managing changes
	vim.pack.add({ gh("lewis6991/gitsigns.nvim") })
	require("gitsigns").setup({
		signs = {
			add = { text = "+" }, ---@diagnostic disable-line: missing-fields
			change = { text = "~" }, ---@diagnostic disable-line: missing-fields
			delete = { text = "_" }, ---@diagnostic disable-line: missing-fields
			topdelete = { text = "‾" }, ---@diagnostic disable-line: missing-fields
			changedelete = { text = "~" }, ---@diagnostic disable-line: missing-fields
		},
	})

	-- Useful plugin to show you pending keybinds.
	vim.pack.add({ gh("folke/which-key.nvim") })
	require("which-key").setup({
		-- Delay between pressing a key and opening which-key (milliseconds)
		delay = 0,
		icons = { mappings = vim.g.have_nerd_font },
		-- Document existing key chains
		spec = {
			{ "<leader>s", group = "[S]earch", mode = { "n", "v" } },
			{ "<leader>t", group = "[T]oggle" },
			{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } }, -- Enable gitsigns recommended keymaps first
			{ "gr", group = "LSP Actions", mode = { "n" } },
		},
	})

	-- [[ Colorscheme ]]
	-- You can easily change to a different colorscheme.
	-- Change the name of the colorscheme plugin below, and then
	-- change the command under that to load whatever the name of that colorscheme is.
	--
	-- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
	vim.pack.add({ gh("folke/tokyonight.nvim") })
	---@diagnostic disable-next-line: missing-fields
	config = function()
		local transparent = false -- set to true if you would like to enable transparency

		-- local bg = "#011628"
		local bg = "#021624"
		local bg_dark = "#011423"
		local bg_highlight = "#143652"
		local bg_search = "#0A64AC"
		local bg_visual = "#275378"
		local fg = "#CBE0F0"
		local fg_dark = "#B4D0E9"
		local fg_gutter = "#627E97"
		local border = "#547998"
		require("tokyonight").setup({
			style = "night",
			styles = {
				comments = { italic = false }, -- Disable italics in comments
				sidebars = transparent and "transparent" or "dark",
				floats = transparent and "transparent" or "dark",
				functions = {},
			},
			on_colors = function(colors)
				colors.bg = bg
				colors.bg_dark = transparent and colors.none or bg_dark
				colors.bg_float = transparent and colors.none or bg_dark
				colors.bg_highlight = bg_highlight
				colors.bg_popup = bg_dark
				colors.bg_search = bg_search
				colors.bg_sidebar = transparent and colors.none or bg_dark
				colors.bg_statusline = transparent and colors.none or bg_dark
				colors.bg_visual = bg_visual
				colors.border = border
				colors.fg = fg
				colors.fg_dark = fg_dark
				colors.fg_float = fg
				colors.fg_gutter = fg_gutter
				colors.fg_sidebar = fg_dark
			end,
		})
	end

	-- Load the colorscheme here.
	-- Like many other themes, this one has different styles, and you could load
	-- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
	vim.cmd.colorscheme("tokyonight")

	-- Highlight todo, notes, etc in comments
	vim.pack.add({ gh("folke/todo-comments.nvim") })
	require("todo-comments").setup({ signs = false })

	-- [[ mini.nvim ]]
	--  A collection of various small independent plugins/modules
	vim.pack.add({ gh("nvim-mini/mini.nvim") })

	-- Better Around/Inside textobjects
	--
	-- Examples:
	--  - va)  - [V]isually select [A]round [)]paren
	--  - yiiq - [Y]ank [I]nside [I]+1 [Q]uote
	--  - ci'  - [C]hange [I]nside [']quote
	require("mini.ai").setup({
		-- NOTE: Avoid conflicts with the built-in incremental selection mappings on Neovim>=0.12 (see `:help treesitter-incremental-selection`)
		mappings = {
			around_next = "aa",
			inside_next = "ii",
		},
		n_lines = 500,
	})

	-- Add/delete/replace surroundings (brackets, quotes, etc.)
	--
	-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
	-- - sd'   - [S]urround [D]elete [']quotes
	-- - sr)'  - [S]urround [R]eplace [)] [']
	require("mini.surround").setup({
		mappings = {
			add = "<leader>ma",
			delete = "<leader>md",
			replace = "<leader>mr",
		},
	})
	-- Simple and easy statusline.
	--  You could remove this setup call if you don't like it,
	--  and try some other statusline plugin
	local statusline = require("mini.statusline")
	-- Set `use_icons` to true if you have a Nerd Font
	statusline.setup({ use_icons = vim.g.have_nerd_font })

	-- You can configure sections in the statusline by overriding their
	-- default behavior. For example, here we set the section for
	-- cursor location to LINE:COLUMN
	---@diagnostic disable-next-line: duplicate-set-field
	statusline.section_location = function()
		return "%2l:%-2v"
	end

	-- ... and there is more!
	--  Check out: https://github.com/nvim-mini/mini.nvim
end
