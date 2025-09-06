local functions = require "functions"
local set = vim.keymap.set

set("n", "-", ":Oil<CR>", { desc = "Open Oil" })
set("n", "<leader>w", ":write<CR>", { desc = "Write File" })
set("n", "<leader>q", ":quit<CR>", { desc = "Close Buffer" })

set('i', '<C-F>', require "plugins.copilot".copilot_suggest, { expr = true,replace_keycodes= false, silent = true, desc = "Suggest/Accept Copilot" })


set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
set("n", "n", "nzzzv", { desc = "Next search result and center" })
set("n", "N", "Nzzzv", { desc = "Previous search result and center" })

set("n", "<leader>cc", "<cmd>lclose<CR><cmd>cclose<CR>zz", { desc = "Close quickfix and location list" })
set("n", "<leader>q", "<cmd>copen<CR>zz", { desc = "Open quickfix list" })
set("n", "<leader>Q", "<cmd>cclose<CR>zz", { desc = "Close quickfix list" })

set("n", "<leader>k", "<cmd>cprev<CR>zz", { desc = "Previous quickfix item" })
set("n", "<leader>j", "<cmd>cnext<CR>zz", { desc = "Next quickfix item" })
set("n", "<leader>K", "<cmd>lprev<CR>zz", { desc = "Previous location list item" })
set("n", "<leader>J", "<cmd>lnext<CR>zz", { desc = "Next location list item" })

set(
    { "n", "o", "x" },
    "<M-w>",
    "<cmd>lua require('spider').motion('w')<CR>",
    { desc = "Spider-w" }
)
set(
    { "n", "o", "x" },
    "<M-e>",
    "<cmd>lua require('spider').motion('e')<CR>",
    { desc = "Spider-e" }
)
set(
    { "n", "o", "x" },
    "<M-b>",
    "<cmd>lua require('spider').motion('b')<CR>",
    { desc = "Spider-b" }
)

set("n", "<leader><S-w>", function()
    vim.wo.wrap = not vim.wo.wrap
end, { desc = "Toggle wrap" })

set('n', '<leader>S', '<cmd>lua require("spectre").toggle()<CR>', {
    desc = "Toggle Spectre"
})

set("n", "j", "v:count ? 'j' : 'gj'",
    { expr = true, desc = "Move down with count support for wrapping lines" })
set("n", "k", "v:count ? 'k' : 'gk'", { expr = true, desc = "Move up with count support for wrapping lines" })


set('s', '<S-j>', 'j', { noremap = true, desc = "Move down in select mode" })
set('s', '<S-k>', 'k', { noremap = true, desc = "Move up in select mode" })
set('s', '<S-h>', 'h', { noremap = true, desc = "Move left in select mode" })
set('s', '<S-l>', 'l', { noremap = true, desc = "Move right in select mode" })


set("n", "g.", [[/\V\C<C-r>"<CR>cgn<C-a><Esc>]],
    { noremap = true, silent = true, desc = "Repeat last action on the removed word" })

set("n", "<leader>bd", functions.buffer_delete, { desc = "Delete buffer" })
set("n", "<leader>bo", function()
    local current_buf = vim.api.nvim_get_current_buf()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if buf ~= current_buf then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end
end, { desc = "Delete all buffers but current" })

set("n", "<leader>r", function()
    vim.cmd("nohlsearch")
end, { desc = "Reset current search" })


local harpoon = require("harpoon")
harpoon:setup()
set("n", "<leader>a", function() harpoon:list():add() end)
set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
set("n", "<leader>1", function() harpoon:list():select(1) end)
set("n", "<leader>2", function() harpoon:list():select(2) end)
set("n", "<leader>3", function() harpoon:list():select(3) end)
set("n", "<leader>4", function() harpoon:list():select(4) end)
set("n", "<C-S-P>", function() harpoon:list():prev() end)
set("n", "<C-S-N>", function() harpoon:list():next() end)

set("n", "<leader>u", vim.cmd.UndotreeToggle)

set("n", "<leader>oi", ":TSToolsOrganizeImports<CR>", { silent = true, desc = "Organize Imports" })

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
        local opts = { buffer = args.buf, remap = false }
        local buf = vim.lsp.buf
        local diagnostic = vim.diagnostic

        set("n", "<leader>ff", function() buf.format() end, opts)
        set("n", "gd", function() buf.definition() end, opts)
        set("n", "gD", function() buf.declaration() end, opts)
        set("n", "go", function() buf.type_definition() end, opts)
        set("n", "K", function() buf.hover() end, opts)
        set("n", "gl", function() diagnostic.open_float() end, opts)
        set("n", "<leader>vws", function() buf.workspace_symbol() end, opts)
        set("n", "<leader>vd", function() diagnostic.open_float() end, opts)

        set("n", "<leader>vca", function() buf.code_action() end, opts)
        set("n", "<leader>vrr", function() buf.references({ includeDeclaration = false }) end, opts)
        set("n", "<leader>vrn", function() buf.rename() end, opts)
        set("i", "<C-e>", function() buf.signature_help() end, opts)

        local jump_opts = function(dir)
            return {
                count = dir,
                severity = diagnostic.severity.ERROR
            }
        end
        set("n", "<leader>e", function() diagnostic.jump(jump_opts(1)) end, opts)
        set("n", "<leader>E", function() diagnostic.jump(jump_opts(-1)) end, opts)

        set("n", "<leader>i",
            function()
                buf.code_action({
                    apply = true,
                    filter = function(action)
                        return action.title:find("import") ~=
                            nil
                    end
                })
            end, opts)
    end,
})

local fzf = require('fzf-lua')


local function get_current_cwd()
    local cwd = vim.fn.expand('%:p:h')
    if cwd:match('^oil://') then
        cwd = cwd:gsub('^oil://', '')
    end
    return cwd
end

set('n', '<leader>pf', function() fzf.files() end, { desc = "find files" })
set('n', '<leader>Pf', function() fzf.files({ cwd = get_current_cwd(), cwd_only = true }) end,
    { desc = "find files in current directory" })
set('n', '<C-p>', function() fzf.git_files() end, { desc = "find git files" })
set('n', '<leader>ps', function() fzf.grep() end, { desc = "search in files" })
set('n', '<leader>pl', function() fzf.live_grep() end, { desc = "live grep in files" })
set('n', '<leader>Pl', function() fzf.live_grep({ cwd = get_current_cwd() }) end,
    { desc = "live grep in current directory" })
set('n', '<leader>pw', function() fzf.grep_cword() end, { desc = "search current word" })
set('n', '<leader>pW', function() fzf.grep_cWORD() end, { desc = "search current WORD" })
set('x', '<leader>pd', function() fzf.grep_visual() end, { desc = "search visual selection" })
set('n', '<Leader>bf', function() fzf.buffers() end, { desc = "find buffers" })
set('n', '<Leader>fl', function() fzf.lgrep_curbuf() end, { desc = "search in current buffer" })
set('n', '<Leader>fe', function() fzf.diagnostics_document() end, { desc = "diagnostics in current buffer" })

set({ "i" }, "<C-x><C-f>",
    function()
        fzf.complete_file({
            cmd = "rg --files",
            winopts = { preview = { hidden = "nohidden" } }
        })
    end, { silent = true, desc = "Fuzzy complete file" })


set('x', '<leader>cl', function()
    vim.cmd([[normal! yoconsole.log("pa", pa);0]])
end, { noremap = true, silent = true, desc = "Insert console.log" })

set("n", "<leader>cl", functions.log_variable, { noremap = true, silent = true, desc = "Log variable" })
set({ "n", "x" }, "<leader>ccb", functions.comment_box, { noremap = true, silent = true, desc = "Comment box" })
set({ "n", "x" }, "<leader>ccl", functions.comment_line, { noremap = true, silent = true, desc = "Comment line" })


local ls = require "luasnip"
-- set("i", "<C-e>", function() ls.expand() end, { silent = true, desc = "Expand snippet" })
set({ "i", "s" }, "<C-j>", function() ls.jump(1) end,
    { noremap = true, silent = true, desc = "Jump to next snippet node" })
set({ "i", "s" }, "<C-k>", function() ls.jump(-1) end,
    { noremap = true, silent = true, desc = "Jump to previous snippet node" })


set("n", "<C-j>", "<cmd>TmuxNavigateDown<CR>",
    { noremap = true, silent = true, desc = "Tmux navigate down" })
set("n", "<C-k>", "<cmd>TmuxNavigateUp<CR>",
    { noremap = true, silent = true, desc = "Tmux navigate up" })
set("n", "<C-h>", "<cmd>TmuxNavigateLeft<CR>",
    { noremap = true, silent = true, desc = "Tmux navigate left" })
set("n", "<C-l>", "<cmd>TmuxNavigateRight<CR>",
    { noremap = true, silent = true, desc = "Tmux navigate right" })


set("n", "<leader>z", functions.zoom, { noremap = true, silent = true, desc = "Zoom toggle" })
