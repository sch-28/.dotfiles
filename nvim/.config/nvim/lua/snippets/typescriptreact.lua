local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local l = require("luasnip.extras").lambda
local r = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
local m = require("luasnip.extras").match
local n = require("luasnip.extras").nonempty
local dl = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local types = require("luasnip.util.types")
local conds = require("luasnip.extras.expand_conditions")
local isn = ls.indent_snippet_node
local events = require("luasnip.util.events")

local function add_react_hook_import(hook)
    -- Search for 'import ... from "react"' in the buffer
    local found = vim.fn.search("import.*'react'", "nw")
    if found == 0 then
        -- No import from React found, insert at top
        vim.api.nvim_buf_set_lines(0, 0, 0, false, { "import React, { " .. hook .. " } from 'react';" })
    else
        -- React import exists, check if hook is already included
        local lines = vim.api.nvim_buf_get_lines(0, found - 1, found, false)
        if lines[1] and not lines[1]:match(hook) then
            -- Append hook to existing import
            lines[1] = lines[1]:gsub("{(.-)}", function(inner)
                return "{" .. inner .. ", " .. hook .. "}"
            end)
            vim.api.nvim_buf_set_lines(0, found - 1, found, false, lines)
        end
    end
    return ""
end

local ts_snippets = require("snippets.ts")

local tsx_snippets = {
    -- s({ trig = "export", dscr = "Export statemenit" }, {
    --     t("export "),
    --     i(1, "default"),
    --     t(" "),
    --     i(2, "module"),
    --     t(";"),
    -- }),
    s({ trig = "fn", dscr = "Function declaration" }, {
        t("function "), i(1, "name"), t("("), i(2, "params"), t({ ") {", "\t" }),
        i(0),
        t({ "", "}" }),
    }),
    s({ trig = "t", descr = "tolgee import" }, {
        f(function()
            local imported = false
            imported = vim.fn.search(
                [['@tolgee/react';]],
                "nw"
            ) ~= 0
            if imported then
                return ""
            end
            vim.api.nvim_buf_set_lines(0, 0, 0, false, {
                "import { useTranslate } from '@tolgee/react';",
            })
            return ""
        end, {}),
        t({ "const { t } = useTranslate();" }),
    }),
    s({ trig = "useE", descr = "useEffect hook" }, {
        f(function()
            return add_react_hook_import("useEffect")
        end, {}),
        t({ "useEffect(() => {", "\t" }),
        i(0),
        t({ "", "}, []);" }),
    }),
    s({ trig = "useS", descr = "useState  hook" }, {
        f(function()
            return add_react_hook_import("useState")
        end, {}),
        t("const ["), i(1, "state"), t(", set"), f(function(args)
        return args[1][1]:gsub("^%l", string.upper)
    end, { 1 }), t("] = useState<"), i(2, "type"), t(">("), i(3, "initial"), t(")")
    }),
    s({ trig = "col", descr = "columnHelper accessor" }, {
        t("columnHelper.accessor('"), i(1, "key"), t("',"),
        t({ '{', '' }),
        t("\theader: t("),
        f(function(args)
            return '"' .. args[1][1] .. '"'
        end, { 1 }),
        t({ "),", "" }),
        t("}),"),
    }),
}
for _, snip in ipairs(ts_snippets) do
    table.insert(tsx_snippets, snip)
end

return tsx_snippets
