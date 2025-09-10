vim.g.mapleader = " "
vim.opt.jumpoptions = ""

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

vim.o.winborder = "rounded"
vim.lsp.document_color.enable()

vim.o.undodir = os.getenv("HOME") .. "/.local/share/nvim/undodir"
vim.o.undofile = true
vim.o.swapfile = false

vim.o.ignorecase = true
vim.o.smartcase = true
vim.cmd([[autocmd FileType * set formatoptions-=ro]])


vim.o.scrolloff = 10
vim.o.signcolumn = "number"

vim.o.termguicolors = true

vim.o.splitbelow = true
vim.o.splitright = true

vim.o.showtabline = 0
-- vim.o.conceallevel = 1
