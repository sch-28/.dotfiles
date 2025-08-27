-- keybdind to dismiss github copilot suggestion
vim.api.nvim_set_keymap('i', '<C-w>', '<Plug>(copilot-dismiss)', { noremap = true, silent = true })
-- map accect to  C-j
vim.cmd([[
        imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")
        let g:copilot_no_tab_map = v:true
]])

-- disable copilot
vim.g.copilot_enabled = false

-- toggle copilot
vim.api.nvim_set_keymap('n', '<leader>cc', "",
    {
        callback = function()
            print(vim.g.copilot_enabled)
            if vim.g.copilot_enabled == 0 or vim.g.copilot_enabled == false then
                vim.cmd('Copilot enable')
                vim.g.copilot_enabled = 1
            else
                vim.cmd('Copilot disable')
                vim.g.copilot_enabled = 0
            end
        end,
        noremap = true,
        silent = true
    })
