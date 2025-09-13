--  ── check if fuzzy is installed, if not build it ──────────────────────────
local location = vim.fn.stdpath "data" .. "/site/pack/core/opt/blink.cmp/"
-- check if 'target' folder exists, if it doesn't run cargo build
if vim.fn.isdirectory(location .. 'target') == 0 then
    print("Building blink.cmp, please wait...")
    local cmd = "cd " .. location .. " && cargo build --release"
    local result = os.execute(cmd)
    if result == 0 then
        print("blink.cmp built successfully")
    else
        print("Error building blink.cmp")
        print(result)
    end
end

-- local luasnip = require "luasnip"
local blink = require "blink.cmp"

blink.setup({
    signature = { enabled = true },
    completion = {
        documentation = {
            auto_show = true,
            auto_show_delay_ms = 500,
            window = {
                border = "rounded",
                winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:BlinkCmpDocCursorLine,Search:None",
            },
        },
        menu = {
            auto_show = true,
            draw = {
                treesitter = { "lsp" },
                columns = { { "kind_icon", "label", "label_description", gap = 1 }, { "kind" } },
                gap = 2
            },
            border = "rounded",
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:BlinkCmpMenuSelection,Search:None",
        }
    },
    keymap = {
        -- set to 'none' to disable the 'default' preset
        preset = 'default',
        ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
        -- ['<C-e>'] = { 'hide' },
        ['<CR>'] = { 'select_and_accept', 'fallback' },

        ['<Up>'] = { 'select_prev', 'fallback' },
        ['<Down>'] = { 'select_next', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
        ['<C-n>'] = { 'show', 'select_next', 'fallback_to_mappings' },

        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },

        ['<C-j>'] = { 'snippet_forward', 'fallback' },
        ['<C-k>'] = { 'snippet_backward', 'fallback' },

        ['<C-e>'] = { 'show_signature', 'hide_signature', 'fallback' },
    },
    cmdline = {
        keymap = {
            preset = 'inherit',
            ['<Tab>'] = { 'accept' },
            ['<CR>'] = { 'accept_and_enter', 'fallback' },
        },
        completion = { menu = { auto_show = true } },
    },
    sources = {
        providers = {
            cmdline = {
                min_keyword_length = function(ctx)
                    -- when typing a command, only show when the keyword is 3 characters or longer
                    if ctx.mode == 'cmdline' and string.find(ctx.line, ' ') == nil then return 3 end
                    return 0
                end
            }
        }
    }
})
