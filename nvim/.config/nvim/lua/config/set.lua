vim.opt.nu = true
vim.opt.relativenumber = true


vim.o.sessionoptions="blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false
vim.opt.linebreak = true

-- vim.api.nvim_exec("language en_US", true)
--set local spellchecking to en
vim.opt.spelllang = "en_us"
vim.opt.swapfile = false
vim.opt.backup = false
vim.o.undodir = os.getenv("HOME") .. "/.local/share/nvim/undodir"
vim.o.undofile = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 10
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50
vim.opt.timeoutlen = 300

vim.opt.inccommand = "split"


vim.opt.colorcolumn = ""

vim.opt.clipboard = "unnamed,unnamedplus"

if vim.fn.has("wsl") == 1 then
    vim.g.clipboard = {
        name = "win32yank-wsl",
        copy = {
            ["+"] = "win32yank.exe -i --crlf",
            ["*"] = "win32yank.exe -i --crlf",
        },
        paste = {
            ["+"] = "win32yank.exe -o --lf",
            ["*"] = "win32yank.exe -o --lf",
        },
        cache_enabled = 0,
    }
end

require("nightfox").setup({
    palettes = {
        nightfox = {
            comment = "#859289",
        }
    },
    options = {
        transparent = true,
        styles = {
            comments = "NONE",
        }
    }
})

local set_hl_for_floating_window = function()
    vim.api.nvim_set_hl(0, 'NormalFloat', {
        link = 'Normal',
    })
    vim.api.nvim_set_hl(0, 'FloatBorder', {
        bg = 'none',
    })
end

set_hl_for_floating_window()
vim.api.nvim_create_autocmd('ColorScheme', {
    pattern = '*',
    desc = 'Avoid overwritten by loading color schemes later',
    callback = set_hl_for_floating_window,
})

-- vim.opt.background = "dark"
vim.cmd.colorscheme("nightfox")


-- autoread file on change
-- vim.o.autoread = true
-- vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained" }, {
--   command = "if mode() != 'c' | checktime | endif",
--   pattern = { "*" },
-- })

-- vim.g.user_emmet_leader_key = "<C-z>"

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.cmd([[autocmd FileType * set formatoptions-=ro]])

vim.opt.virtualedit = "all"



-- Set a red background for errors, removing any underline or undercurl

vim.opt.cursorcolumn = false
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"

-- vim.lsp.enable({'clangd', 'gopls'})
-- vim.diagnostic.config({ virtual_text = { current_line = true } })
-- vim.o.winbl = 10
-- vim.o.winblend = 10
-- vim.api.nvim_set_hl(0, 'NormalFloat', {link = 'CmpItemMenu'})
