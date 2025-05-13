local cmp = require('cmp')
local icons = require("utils.icons")
local cmp_action = require('lsp-zero').cmp_action()
local luasnip = require("luasnip")

--- Get completion context, i.e., auto-import/target module location.
--- Depending on the LSP this information is stored in different parts of the
--- lsp.CompletionItem payload. The process to find them is very manual: log the payloads
--- And see where useful information is stored.
---@param completion lsp.CompletionItem
---@param source cmp.Source
local function get_lsp_completion_context(completion, source)
    local ok, source_name = pcall(function() return source.source.client.config.name end)
    if not ok then
        return nil
    end
    -- print(vim.inspect(completion))

    if source_name == "tsserver" then
        return completion.detail
    elseif source_name == "typescript-tools" then
        return completion.data.entryNames[1].source
    elseif source_name == "gopls" then
        -- And this, for the record, is how I inspect payloads
        -- require("ditsuke.utils").logger("completion source: ", completion) -- Lazy-serialization of heavy payloads
        -- require("ditsuke.utils").logger("completion detail added to gopls")
        return completion.detail
    end
end


-- C-space mapping doesnt work for some reasons
-- vim.cmd([[inoremap <C-Space> <C-x><C-o>
--  inoremap <C-@> <C-Space>]])
cmp.setup({
    preselect = cmp.PreselectMode.None,
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body) -- For `luasnip` users.
        end,
    },
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    }, {
        { name = 'buffer' },
    }),
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
        -- instead no dashed border:

        -- window = {
        --     documentation = {
        --         border = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' },
        --     },
        --     completion = {
        --         border = { '┌', '─', '┐', '│', '┘', '─', '└', '│' },
        --         winhighlight = 'Normal:CmpPmenu,FloatBorder:CmpPmenuBorder,CursorLine:PmenuSel,Search:None',
        --     }
        -- },
    },
    view = {
        entries = 'custom'
    },
    mapping = cmp.mapping.preset.insert({
        -- `Enter` key to confirm completion
        -- ['<CR>'] = cmp.mapping.confirm({ select = false }),

        -- Ctrl+Space to trigger completion menu
        ['<C-y>'] = cmp.mapping.complete(),

        -- Navigate between snippet placeholder
        ['<C-f>'] = cmp_action.luasnip_jump_forward(),
        ['<C-b>'] = cmp_action.luasnip_jump_backward(),

        -- Scroll up and down in the completion documentation
        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),
        ['<Tab>'] = cmp_action.luasnip_supertab(),


        ['<CR>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                if luasnip.expandable() then
                    luasnip.expand()
                else
                    cmp.confirm({
                        behavior = cmp.ConfirmBehavior.Insert,
                        select = false,
                    })
                end
            else
                fallback()
            end
        end),

        -- ["<Tab>"] = cmp.mapping(function(fallback)
        --     if cmp.visible() then
        --         cmp.select_next_item()
        --     elseif luasnip.locally_jumpable(1) then
        --         luasnip.jump(1)
        --     else
        --         fallback()
        --     end
        -- end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
    }),
    formatting = {
        --- @type cmp.ItemField[]
        fields = {
            "kind",
            "abbr",
            "menu",
        },

        --- @param entry cmp.Entry
        --- @param vim_item vim.CompletedItem
        format = function(entry, vim_item)
            local item_with_kind = require("lspkind").cmp_format({
                -- mode = "symbol",
                -- maxwidth = 50,
                -- symbol_map = icons.cmp_types,
                mode = 'symbol', -- show only symbol annotations
                maxwidth = {
                    -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
                    -- can also be a function to dynamically calculate max width such as
                    -- menu = function() return math.floor(0.45 * vim.o.columns) end,
                    menu = 50,  -- leading text (labelDetails)
                    abbr = 50,  -- actual suggestion item
                },
                ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
                show_labelDetails = true, -- show labelDetails in menu. Disabled by default

                -- The function below will be called before any actual modifications from lspkind
                -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
                before = function(entry, vim_item)
                    -- ...
                    return vim_item
                end
            })(entry, vim_item)


            item_with_kind.menu = ""
            local completion_context = get_lsp_completion_context(entry.completion_item, entry.source)
            if completion_context ~= nil and completion_context ~= "" then
                local truncated_context = string.sub(completion_context, 1, 30)
                if truncated_context ~= completion_context then
                    truncated_context = truncated_context .. icons.misc.ellipsis
                end
                item_with_kind.menu = item_with_kind.menu .. " " .. truncated_context
            end

            item_with_kind.menu_hl_group = "CmpItemAbbr"
            return item_with_kind
        end,
    },
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
    }
})
--
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    }),
    matching = { disallow_symbol_nonprefix_matching = false }
})
