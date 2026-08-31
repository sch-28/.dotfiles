-- GUI launches (rofi/xdg-open) inherit the WM's PATH, not the shell's, so
-- tool checks below would miss cargo/tree-sitter and reinstall them each start.
for _, dir in ipairs {
    vim.env.HOME .. "/.local/bin",
    vim.env.HOME .. "/.cargo/bin",
    vim.env.HOME .. "/.local/share/bob/nvim-bin",
    vim.fn.stdpath "data" .. "/mason/bin",
} do
    if vim.fn.isdirectory(dir) == 1 and not string.find(vim.env.PATH, dir, 1, true) then
        vim.env.PATH = dir .. ":" .. vim.env.PATH
    end
end

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
