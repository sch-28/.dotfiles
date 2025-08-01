vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
vim.g.fugitive_summary_format = "%an\t%as (%ar) | %s"
vim.keymap.set("n", "<leader>gh", "<cmd>0GlLog<CR>")
vim.keymap.set("n", "<leader>gd", "<cmd>Gdiff<CR>")
vim.keymap.set("n", "<leader>ge", "<cmd>Gedit<CR><C-w>o")
