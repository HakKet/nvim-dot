vim.pack.add({
	{ src = "https://github.com/github/copilot.vim" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/CopilotC-Nvim/CopilotChat.nvim" },
})

-- copilot.vim: avoid hijacking <Tab>
vim.g.copilot_no_tab_map = true

vim.keymap.set("i", "<C-J>", 'copilot#Accept("\\<CR>")', {
	expr = true,
	replace_keycodes = false,
	silent = true,
	desc = "Accept Copilot suggestion",
})

vim.keymap.set("i", "<M-]>", "<Plug>(copilot-next)", { desc = "Next Copilot suggestion" })
vim.keymap.set("i", "<M-[>", "<Plug>(copilot-previous)", { desc = "Previous Copilot suggestion" })
vim.keymap.set("i", "<M-\\>", "<Plug>(copilot-dismiss)", { desc = "Dismiss Copilot suggestion" })

require("CopilotChat").setup({
	model = "gpt-4.1",
	temperature = 0.1,
	auto_insert_mode = true,
	window = {
		layout = "vertical",
		width = 0.4,
	},
})

vim.keymap.set("n", "<leader>cc", function()
	require("CopilotChat").open()
end, { desc = "Open Copilot Chat" })

vim.keymap.set("n", "<leader>cx", function()
	require("CopilotChat").reset()
end, { desc = "Reset Copilot Chat" })

vim.keymap.set("v", "<leader>ce", function()
	require("CopilotChat").prompt("Explain this code")
end, { desc = "Explain code" })

vim.keymap.set("v", "<leader>cf", function()
	require("CopilotChat").prompt("Fix this code")
end, { desc = "Fix code" })
