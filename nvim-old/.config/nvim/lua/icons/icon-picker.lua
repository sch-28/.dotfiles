local has_telescope, telescope = pcall(require, "telescope")

-- TODO: make dependency errors occur in a better way
if not has_telescope then
    error("This plugin requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)")
end


local utils = require('telescope.utils')
local defaulter = utils.make_default_callable
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local previewers = require('telescope.previewers')
local conf = require('telescope.config').values
local icons = require('icons.lucide-icons')
local icon_font = require("icons.lucide-font")
local entry_display = require("telescope.pickers.entry_display")

-- iterate icons and icon_font, and put the glyph of icon_font into the icon table
for i, icon in ipairs(icons) do
    local icon_name = icon.name
    local icon_glyph = icon_font[i].unicode
    if icon_glyph then
        icon.symbol = icon_glyph
    else
        print("Icon " .. icon_name .. " not found in icon_font")
    end
end

local M = {}

local filetypes = {}
local find_cmd = "rg"
local image_stretch = 250

M.base_directory = os.getenv("HOME") .. "/.config/nvim/lua/icons"
M.svg_preview = defaulter(function(opts)
    return previewers.new_termopen_previewer {
        get_command = opts.get_command or function(entry)
            local svg = M.base_directory .. "/lucide_icons/" .. entry.value.name .. ".svg"
            -- local tmp_table = vim.split(svg, "\t");

            local preview = opts.get_preview_window()
            -- if vim.tbl_isempty(tmp_table) then
            --     return { "echo", "" }
            -- end
            return {
                "/bin/bash", M.base_directory .. '/vimg.sh',
                svg,
                preview.col,
                preview.line + 1,
                16,
                16,
                image_stretch
            }
        end
    }
end, {})

function M.icons(opts)
    local find_commands = {
        find = {
            'find',
            '.',
            '-iregex',
            [[.*\.\(]] .. table.concat(filetypes, "\\|") .. [[\)$]]
        },
        fd = {
            'fd',
            '--type',
            'f',
            '--regex',
            [[.*.(]] .. table.concat(filetypes, "|") .. [[)$]],
            '.'
        },
        fdfind = {
            'fdfind',
            '--type',
            'f',
            '--regex',
            [[.*.(]] .. table.concat(filetypes, "|") .. [[)$]],
            '.'
        },
        rg = {
            'rg',
            '--files',
            '--glob',
            [[*.{]] .. table.concat(filetypes, ",") .. [[}]],
            '.'
        },
    }

    if not vim.fn.executable(find_cmd) then
        error("You don't have " .. find_cmd .. "! Install it first or use other finder.")
        return
    end

    if not find_commands[find_cmd] then
        error(find_cmd .. " is not supported!")
        return
    end

    local sourced_file = require('plenary.debug_utils').sourced_filepath()
    opts = opts or {}
    -- opts.attach_mappings= function(prompt_bufnr,map)
    --   actions.select_default:replace(function()
    --     local entry = action_state.get_selected_entry()
    --     actions.close(prompt_bufnr)
    --     if entry[1] then
    --       local filename = entry[1]
    --       vim.fn.setreg(vim.v.register, filename)
    --       vim.notify("The image path has been copied!")
    --     end
    --   end)
    --   return true
    -- end
    opts.path_display = { "shorten" }

    local popup_opts = {}
    opts.get_preview_window = function()
        return popup_opts.preview
    end

    local displayer = entry_display.create {
        separator = " ",
        items = {
            -- { width = 2 },       -- icon glyph
            { width = 30 },       -- name
            { width = 30 },       -- categories
            { remaining = true }, -- extra metadata
        },
    }


    local function decode_unicode_escape(str)
        local hex = str:match("\\(e%x+)")
        if hex then
            local new_hex = vim.fn.nr2char(tonumber(hex, 16) - 1)
            return new_hex
        end
        return str
    end

    local make_display = function(entry)
        local symbol = decode_unicode_escape(entry.value.symbol)
        return displayer {
            -- symbol,
            entry.value.name,
            table.concat(entry.value.categories, ", "),
            table.concat(entry.value.tags, ", "),
        }
    end

    local picker = pickers.new(opts, {
        prompt_title = 'Icons',
        finder = finders.new_table {
            results = icons,
            entry_maker = function(entry)
                -- Create fuzzy searchable text from name + tags + categories
                local search_key = entry.name ..
                    " " .. table.concat(entry.tags or {}, " ") .. " " .. table.concat(entry.categories or {}, " ")

                return {
                    value = entry,
                    display = make_display,
                    ordinal = search_key,
                }
            end
        },
        previewer = M.svg_preview.new(opts),
        sorter = conf.file_sorter(opts),
    })


    local line_count = vim.o.lines - vim.o.cmdheight
    if vim.o.laststatus ~= 0 then
        line_count = line_count - 1
    end
    popup_opts = picker:get_window_options(vim.o.columns, line_count)
    picker:find()
end

-- return require('telescope').register_extension {
--   setup = function(ext_config)
--     filetypes = ext_config.filetypes or {"png", "jpg", "gif", "mp4", "webm", "pdf"}
--     find_cmd = ext_config.find_cmd or "fd"
--     image_stretch = ext_config.image_stretch or 250
--   end,
--   exports = {
--     icons = M.icons
--   },
-- }

return {
    pick = M.icons
}
