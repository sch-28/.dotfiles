return {
    name = "eslint",
    builder = function()
        -- Full path to current file (see :help expand())
        local file = vim.fn.expand("%:p")
        return {
            cmd = { "bun" },
            -- args = { file },
            args = { "run", "lint:clean" },
            components = {
                -- { "on_output_quickfix", open = true },
                {
                    "on_output_parse",
                    parser = {
                        diagnostics = {

                            { "extract",  "(%/home[^:]+.[tsx|ts])", "filename" },
                            {
                                "loop",
                                {
                                    "extract",
                                    { regex = true },
                                    "\\v\\s+(\\d+):(\\d+)\\s+(error|warning|info)\\s+(.{-1,})%(\\s\\s+(.*))?$",
                                    "lnum",
                                    "col",
                                    "severity",
                                    "text",
                                },
                            },

                            { "dispatch", "set_results" },
                        }
                    }
                },
                { "on_result_diagnostics_quickfix", open = true },
                "on_exit_set_status",
            },
        }
    end,
    condition = {
        filetype = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    },
}
