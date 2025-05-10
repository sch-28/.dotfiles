-- keybdind to dismiss github copilot suggestion
vim.api.nvim_set_keymap('i', '<C-w>', '<Plug>(copilot-dismiss)', { noremap = true, silent = true })
-- map accect to  C-j
vim.cmd([[
        imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")
        let g:copilot_no_tab_map = v:true
]])
