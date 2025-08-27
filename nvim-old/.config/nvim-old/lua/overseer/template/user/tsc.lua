return {
    name = "tsc",
    builder = function()
        -- Full path to current file (see :help expand())
        local file = vim.fn.expand("%:p")
        return {
            cmd = { "bun" },
            -- args = { file },
            args = { "run", "build:check:clean" },
            components = {
                {"on_output_parse", problem_matcher = "$tsc"},
                { "on_result_diagnostics_quickfix", open = true },
                "on_exit_set_status",
            }
        }
    end,
    condition = {
        filetype = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    },
}
