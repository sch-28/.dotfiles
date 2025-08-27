require "set"
require "plugin"
require "mappings"
require "lsp"

vim.api.nvim_set_hl(0, 'NormalFloat', {
	link = 'Normal',
})

vim.api.nvim_set_hl(0, 'FloatBorder', {
	bg = 'none',
})
