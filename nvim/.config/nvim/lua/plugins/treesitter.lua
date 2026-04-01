--  ── check if tree-sitter CLI is installed, if not install it ────────────────
local ts_bin = vim.fn.expand("~/.cargo/bin/tree-sitter")
if vim.fn.filereadable(ts_bin) == 0 then
    print("Installing tree-sitter CLI, please wait...")
    local result = os.execute("cargo install --locked tree-sitter-cli")
    if result == 0 then
        print("tree-sitter CLI installed successfully")
    else
        print("Error installing tree-sitter CLI")
        print(result)
    end
end

require('nvim-treesitter').setup {
  -- Directory to install parsers and queries to
  install_dir = vim.fn.stdpath('data') .. '/site'
}

-- Install parsers (no-op if already installed)
require('nvim-treesitter').install({
  'c', 'lua', 'vim', 'vimdoc', 'query', 'markdown', 'markdown_inline'
})

-- Enable treesitter highlighting per filetype, with a file size guard
vim.api.nvim_create_autocmd('FileType', {
  callback = function(ev)
    local max_filesize = 100 * 1024 -- 100 KB
    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(ev.buf))
    if ok and stats and stats.size > max_filesize then
      return
    end
    pcall(vim.treesitter.start)
  end,
})

require('treesitter-context').setup {
  enable = true,
  max_lines = 0,
  min_window_height = 0,
  line_numbers = true,
  multiline_threshold = 1,
  trim_scope = 'outer',
  mode = 'cursor',
  separator = nil,
  zindex = 20,
  on_attach = nil,
}

vim.cmd('hi link TreesitterContextSeparator VertSplit')
vim.cmd('hi TreesitterContextBottom gui=underline guisp=Grey')
vim.cmd('hi TreesitterContext guibg=bg+10 guifg=fg')
