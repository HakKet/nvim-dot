vim.api.nvim_create_user_command("ExportKeymapsMarkdown", function()
	require("hakan.tools.export_keymaps").export_markdown()
end, {})
