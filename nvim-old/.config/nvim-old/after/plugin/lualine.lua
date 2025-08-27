
local colors = {
    bg       = '#202328',
    fg       = '#bbc2cf',
    yellow   = '#ECBE7B',
    cyan     = '#008080',
    darkblue = '#081633',
    green    = '#98be65',
    orange   = '#FF8800',
    violet   = '#a9a1e1',
    magenta  = '#c678dd',
    blue     = '#51afef',
    red      = '#ec5f67',
}


vim.api.nvim_set_hl(0, 'LualineRed', { fg = colors.red, bg = colors.bg })

local function neomakeLoading()
    local frames = { '◐', '◓', '◑', '◒' }
    local i = math.floor(vim.loop.hrtime() / 100000000) -- every 0.1s
    local spinner = frames[(i % #frames) + 1]

    local bufnr = vim.api.nvim_get_current_buf()
    local num_issues = #vim.fn.getqflist()

    if num_issues == 1 then
        local qflist = vim.fn.getqflist()
        if qflist[1].text:match('No targets specified') then
            return 'ok'
        end
    end

    local status = vim.fn['neomake#statusline#get'](bufnr, {
        format_running = spinner,
        format_loclist_ok = 'ok', -- shown if clean (no issues)
        format_quickfix_ok = 'ok', -- unused, we rely on quickfix_issues
        format_quickfix_issues = '%s',
        format_status = '%s',
        format_default = ""
    })


    if status:sub(1, 2) == '? ' then
        status = status:sub(3)
    end

    -- replace QE: with QF:
    status = status:gsub('QE:', '')

    --remove all bg colors
    status = status:gsub('%%#.-# ', '%%#LualineRed# %%#LualineRed#')

    return status
end
local conditions = {
    buffer_not_empty = function()
        return vim.fn.empty(vim.fn.expand('%:t')) ~= 1
    end,
    hide_in_width = function()
        return vim.fn.winwidth(0) > 80
    end,
    check_git_workspace = function()
        local filepath = vim.fn.expand('%:p:h')
        local gitdir = vim.fn.finddir('.git', filepath .. ';')
        return gitdir and #gitdir > 0 and #gitdir < #filepath
    end,
}

local function copilot_status()
    local status = vim.g.copilot_enabled
    if status == 1 then
        status = "on"
    else
        status = "off"
    end

    return "c-"..status
end



local lualine = require('lualine')


local config = {
    options = {
        theme = {
            -- We are going to use lualine_c an lualine_x as left and
            -- right section. Both are highlighted by c theme .  So we
            -- are just setting default looks o statusline
            normal = { c = { fg = colors.fg, bg = colors.bg } },
            inactive = { c = { fg = colors.fg, bg = colors.bg } },
        },
        component_separators = {},
        section_separators = {},
        disabled_filetypes = {
            statusline = {},
            winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
            statusline = 100,
            tabline = 500,
            winbar = 500,
        }
    },
    sections = {
        -- these are to remove the defaults
        lualine_a = {},
        lualine_b = {},
        lualine_y = {},
        lualine_z = {},
        -- These will be filled later
        lualine_c = {},
        lualine_x = {},
    },
    inactive_sections = {
        -- these are to remove the defaults
        lualine_a = {},
        lualine_b = {

        },
        lualine_y = {},
        lualine_z = {},
        lualine_c = {
            {
                "filename",
                cond = conditions.buffer_not_empty,
                color = { fg = colors.fg, gui = 'bold' },
                path = 4,
            }
        },
        lualine_x = {},
    },
    tabline = {},
    winbar = {},
    inactive_winbar = {},
    extensions = {}
}

local function ins_left(component)
    table.insert(config.sections.lualine_c, component)
end

-- Inserts a component in lualine_x at right section
local function ins_right(component)
    table.insert(config.sections.lualine_x, component)
end



ins_left {
    'diagnostics',
    sources = { 'nvim_diagnostic' },
    symbols = { error = ' ', warn = ' ', info = ' ' },
    diagnostics_color = {
        error = { fg = colors.red },
        warn = { fg = colors.yellow },
        info = { fg = colors.cyan },
    },
}

ins_left {
    neomakeLoading,
}

ins_left {
    'filename',
    cond = conditions.buffer_not_empty,
    path = 4,
    color = { fg = colors.fg, gui = 'bold' },
}




-- Add components to right sections
ins_right {
    copilot_status,
    color = { fg = colors.fg, gui = 'bold' },
}
ins_right {
    'o:encoding',       -- option component same as &encoding in viml
    fmt = string.upper, -- I'm not sure why it's upper case either ;)
    cond = conditions.hide_in_width,
    color = { fg = colors.fg, gui = 'bold' },
}

ins_right {
    'fileformat',
    fmt = string.upper,
    icons_enabled = false, -- I think icons are cool but Eviline doesn't have them. sigh
    color = { fg = colors.fg, gui = 'bold' },
}

ins_right {
    'branch',
    icon = '',
    color = { fg = colors.fg, gui = 'bold' },
}



-- Now don't forget to initialize lualine
lualine.setup(config)
