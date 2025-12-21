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
    enabled = function()
        return vim.fn.reg_recording() == ''
    end,
    signature = { enabled = true },
    snippets = { preset = 'luasnip' },
    sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
        providers = {
            lsp = {
                name = 'LSP',
                module = 'blink.cmp.sources.lsp',
                opts = {}, -- Passed to the source directly, varies by source
                --- NOTE: All of these options may be functions to get dynamic behavior
                --- See the type definitions for more information
                enabled = true, -- Whether or not to enable the provider
                async = true, -- Whether we should show the completions before this provider returns, without waiting for it
                timeout_ms = 250, -- How long to wait for the provider to return before showing completions and treating it as asynchronous
                transform_items = nil, -- Function to transform the items before they're returned
                should_show_items = true, -- Whether or not to show the items
                max_items = nil, -- Maximum number of items to display in the menu
                min_keyword_length = 0, -- Minimum number of characters in the keyword to trigger the provider
                -- If this provider returns 0 items, it will fallback to these providers.
                -- If multiple providers fallback to the same provider, all of the providers must return 0 items for it to fallback
                fallbacks = {},
                score_offset = 0, -- Boost/penalize the score of the items
                override = nil, -- Override the source's functions
            }
        },
    },
    completion = {
        accept = { auto_brackets = { enabled = false }, },
        documentation = {
            auto_show = true,
            auto_show_delay_ms = 0,
            window = {
                border = "rounded",
                winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:BlinkCmpDocCursorLine,Search:None",
            },
        },
        list = {
            selection = {
                preselect = true,
                auto_insert = false
            }
        },
        menu = {
            auto_show = true,
            draw = {
                -- treesitter = { "lsp" },
                columns = { { "kind_icon", "label", "label_description", gap = 1 }, { "kind" } },
                gap = 2
            },
            border = "rounded",
            winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:BlinkCmpMenuSelection,Search:None",
        },
    },
    keymap = {
        preset = 'none',
        ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-y>'] = { 'select_and_accept', 'fallback' },

        ['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
        ['<C-n>'] = { 'show', 'select_next', 'fallback_to_mappings' },

        ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },

        ['<C-j>'] = { 'snippet_forward', 'fallback' },
        ['<C-k>'] = { 'snippet_backward', 'fallback' },

        ['<C-e>'] = { 'show_signature', 'hide_signature', 'fallback' },
    },
    cmdline = {
        keymap = {
            preset = 'inherit',
            ['<Tab>'] = { 'select_next', 'fallback' },
            ['<S-Tab>'] = { 'select_prev', 'fallback' },
            ['<C-y>'] = { 'accept_and_enter', 'fallback' },
        },
        completion = {
            menu = { auto_show = true },
            list = { selection = { auto_insert = true, preselect = false } }

        },
    },
    -- sources = {
    --     providers = {
    --         cmdline = {
    --             min_keyword_length = function(ctx)
    --                 -- when typing a command, only show when the keyword is 3 characters or longer
    --                 if ctx.mode == 'cmdline' and string.find(ctx.line, ' ') == nil then return 3 end
    --                 return 0
    --             end
    --         }
    --     }
    -- }
})
