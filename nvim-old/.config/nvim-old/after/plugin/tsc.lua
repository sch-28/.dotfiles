local augroup = vim.api.nvim_create_augroup("auto_compiler", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "typescript,typescriptreact",
  group = augroup,
  -- command = "compiler tsc | setlocal makeprg=npx\\ tsc\\ --noEmit\\ --jsx\\ react-jsx\\ --allowSyntheticDefaultImports",
  command = "compiler tsc | setlocal makeprg=pnpm\\ run\\ build:check:clean",
})

