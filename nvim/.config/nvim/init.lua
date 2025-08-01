vim.g.mapleader = " "

vim.o.number = true
vim.o.relativenumber = true

vim.o.sessionoptions="blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

vim.o.tabstop = 4
vim.o.wrap = false
vim.o.smartindent = true
vim.o.linebreak = true
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.virtualedit = "all"

vim.o.winborder = "none"

vim.o.undodir = os.getenv("HOME") .. "/.local/share/nvim/undodir"
vim.o.undofile = true
vim.o.swapfile = false

vim.o.ignorecase = true
vim.o.smartcase = true
-- disable comment insert
vim.cmd([[autocmd FileType * set formatoptions-=ro]])


vim.o.scrolloff = 10
vim.o.signcolumn = "number"

vim.o.termguicolors = true

vim.o.splitbelow = true
vim.o.splitright = true

require "plugin"
require "mappings"
require "lsp"

vim.api.nvim_set_hl(0, 'NormalFloat', {
	link = 'Normal',
})

vim.api.nvim_set_hl(0, 'FloatBorder', {
	bg = 'none',
})
 vim.diagnostic.config({
  float = {
    border = "rounded",
  }
})
