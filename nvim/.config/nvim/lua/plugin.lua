#52342
vim.pack.add({
    { src = "https://github.com/nvim-tree/nvim-web-devicons" },
    { src = "https://github.com/stevearc/oil.nvim" },
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/mason-org/mason.nvim" },
    { src = "https://github.com/mason-org/mason-lspconfig.nvim" },
    { src = "https://github.com/EdenEast/nightfox.nvim" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter-context" },
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/mbbill/undotree" },
    { src = "https://github.com/tpope/vim-fugitive" },
    { src = "https://github.com/windwp/nvim-autopairs" },
    { src = "https://github.com/windwp/nvim-ts-autotag" },
    { src = "https://github.com/github/copilot.vim" },
    { src = "https://github.com/f-person/git-blame.nvim" },
    { src = "https://github.com/dense-analysis/ale" },
    { src = "https://github.com/JoosepAlviste/nvim-ts-context-commentstring" },
    { src = "https://github.com/numToStr/Comment.nvim" },
    { src = "https://github.com/pmizio/typescript-tools.nvim" },
    { src = "https://github.com/nvim-lualine/lualine.nvim" },
    { src = "https://github.com/kylechui/nvim-surround" },
    { src = "https://github.com/ibhagwan/fzf-lua" },
    { src = "https://github.com/ThePrimeagen/harpoon",                       version = "harpoon2" },
    { src = "https://github.com/L3MON4D3/LuaSnip",                           version = "v2.4.0" },
    { src = "https://github.com/m4xshen/hardtime.nvim" },
    { src = "https://github.com/christoomey/vim-tmux-navigator" },
    { src = "https://github.com/Saghen/blink.cmp" },
    { src = "https://github.com/MunifTanjim/nui.nvim" },
})

local inactive_plugins = {}
local plugins = vim.pack.get()
for i, v in ipairs(plugins) do
    if v.active == false then
        table.insert(inactive_plugins, v.spec.name)
    end
end
if #inactive_plugins > 0 then
    vim.pack.del(inactive_plugins)
end

require "oil".setup()
require "nvim-autopairs".setup()
require "nvim-ts-autotag".setup()
require "nvim-surround".setup()
require "hardtime".setup()

require "plugins.comment"
require "plugins.nightfox"
require "plugins.fzf"
require "plugins.git-blame"
require "plugins.lualine"
require "plugins.oil"
require "plugins.treesitter"
require "plugins.ale"
require "plugins.luasnip"
require "plugins.copilot"
require "plugins.blink"
