vim.g.ale_linters_explicit = 1
vim.g.ale_fix_on_save = 1
vim.g.ale_linters = {
    javascript = { "eslint" },
    javascriptreact = { "eslint" },
    typescript = { "eslint" },
    typescriptreact = { "eslint" },
}

vim.g.ale_fixers = {
    javascript = { "prettier" },
    javascriptreact = { "prettier" },
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
}
