local telescope = require('telescope')
local builtin = require('telescope.builtin')
require('telescope').setup({
    defaults = {
        -- set path display to truncate 3
        file_ignore_patterns = { "node_modules", ".git" },
        path_display  = { truncate = 3 },
        layout_config = {
            horizontal = { width = 0.95, preview_width = 0.35, prompt_position = "bottom" },
            -- other layout configuration here
        },
        -- other defaults configuration here
    },
    -- other configuration values here
})

 require'telescope'.setup {
  extensions = {
    media_files = {
      -- filetypes whitelist
      -- defaults to {"png", "jpg", "mp4", "webm", "pdf"}
      filetypes = {"png", "webp", "jpg", "jpeg", "svg"},
      -- find command (defaults to `fd`)
      find_cmd = "rg"
    }
  },
}


-- builtin.load_extension('live_grep_args')

require("telescope").load_extension("live_grep_args")
-- require('telescope').load_extension('icons.icon-picker')

-- require('config.telescopePickers').prettyGrepPicker({ file_picker = 'live_grep' })
-- require('config.telescopePickers').prettyGrepPicker({ file_picker = 'grep_string' })
-- require('config.telescopePickers').prettyFilesPicker({ file_picker = 'git_files' })
-- require('config.telescopePickers').prettyFilesPicker({ file_picker = 'find_files' })
-- require('config.telescopePickers').prettyFilesPicker({ file_picker = 'oldfiles' })

local file_picker = require('config.telescopePickers').prettyFilesPicker
local grep_picker = require('config.telescopePickers').prettyGrepPicker

-- builtin.grep_string({ search = vim.fn.input("Grep > ") });
vim.keymap.set('n', '<leader>pf', function() file_picker({ picker = "find_files",options={hidden=true}  }) end, {})
vim.keymap.set('n', '<C-p>', function() builtin.git_files() end, {})
vim.keymap.set('n', '<leader>ps', function()
    grep_picker({ picker = "grep_string", options = { search = vim.fn.input("Grep > ") } });
end)
vim.keymap.set('n', '<leader>pl', function()
    grep_picker({ picker = "live_grep"});
end)
vim.keymap.set('n', '<leader>pd', function()
    local selected_word = vim.fn.expand("<cword>")
    grep_picker({ picker = "grep_string", options = { search = selected_word } })
end)
vim.keymap.set('n', '<Leader>fl', function() builtin.current_buffer_fuzzy_find() end)
vim.keymap.set('n', '<Leader>pe',
    function() builtin.diagnostics({ initial_mode = "normal", severity = vim.lsp.protocol.DiagnosticSeverity.Error }) end)
vim.keymap.set('n', '<Leader>fe',
    function() builtin.diagnostics({ initial_mode = "normal", bufnr = 0,
            severity = vim.lsp.protocol.DiagnosticSeverity.Error }) end)
vim.keymap.set("n", "<leader>li", require('icons.icon-picker').pick, { desc = "Pick Lucide Icon" })
-- call todo-comments picker
vim.keymap.set('n', "<leader>pt",function() 
    require('telescope').extensions["todo-comments"].todo({
        initial_mode = "normal",
    })
end, { desc = "Telescope Todo Comments" })
