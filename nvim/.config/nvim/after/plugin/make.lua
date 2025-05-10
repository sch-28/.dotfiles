-- vim.cmd([[
--   call neomake#configure#automake('w')
-- ]])
--  augroup my_neomake
--     au! BufWritePost * Neomake!
-- augroup
-- to lua:

local augroup = vim.api.nvim_create_augroup("my_neomake", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*",
    group = augroup,
    callback = function()
        vim.cmd("NeomakeClean!")
        vim.cmd("NeomakeCancelJobs")
        vim.cmd("NeomakeProject")
    end
})
