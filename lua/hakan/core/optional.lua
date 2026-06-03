-- ============================================================
-- SECTION 9: OPTIONAL EXAMPLES / NEXT STEPS
-- hakan.plugins.* examples
-- ============================================================
do
	-- The following comments only work if you have downloaded the hakan repo, not just copy pasted the
	-- init.lua. If you want these files, they are in the repository, so you can just download them and
	-- place them in the correct locations.

	-- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for hakan
	--
	--  Here are some example plugins that I've included in the hakan repository.
	--  Uncomment any of the lines below to enable them (you will need to restart nvim).
	--
	require("hakan.plugins.debug")
	require("hakan.plugins.indent_line")
	require("hakan.plugins.lint")
	require("hakan.plugins.autopairs")
	require("hakan.plugins.neo-tree")
	require("hakan.plugins.gitsigns") -- adds gitsigns recommended keymaps

	-- NOTE: You can add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
	--
	--  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
	require("hakan.plugins")
end
