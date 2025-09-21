local opt = vim.opt
vim.g.mapleader = " "
opt.jumpoptions = ""

opt.number = true
opt.relativenumber = true

opt.tabstop = 4
opt.wrap = false
opt.smartindent = true
opt.linebreak = true
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.numberwidth = 2
opt.signcolumn = "yes:1"
opt.autoindent = true

opt.virtualedit = "all"

opt.winborder = "rounded"
vim.lsp.document_color.enable()

opt.undodir = os.getenv("HOME") .. "/.local/share/nvim/undodir"
opt.undofile = true
opt.swapfile = false

opt.ignorecase = true
opt.smartcase = true
vim.cmd([[autocmd FileType * set formatoptions-=ro]])


opt.scrolloff = 8
opt.termguicolors = true

opt.splitbelow = true
opt.splitright = true

opt.showtabline = 0
opt.scroll = 10

opt.path:append("**")

opt.guicursor = "i:block"
opt.shiftround = true
opt.listchars = "tab: ,multispace:|   "
opt.list = true

-- opt.complete = ".,o"
-- opt.completeopt = "menuone,noinsert,popup"
-- opt.autocomplete = true
-- opt.pumheight = 10
