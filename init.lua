require("hakan.utils")
require("hakan.core")
require("hakan.plugins")

vim.api.nvim_create_user_command("ExportKeymapsMarkdown", function()
	require("export_keymaps").export_markdown()
end, {})
