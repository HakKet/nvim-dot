vim.pack.add { 'https://github.com/kdheepak/lazygit.nvim' }
vim.pack.add { 'https://github.com/nvim-lua/plenary.nvim' }
-- setting the keybinding for LazyGit with 'keys' is recommended in
-- order to load the plugin when the command is run for the first time
vim.keymap.set('n', '<leader>lg', '<cmd>LazyGit<cr>', { desc = 'Open lazy git' })
