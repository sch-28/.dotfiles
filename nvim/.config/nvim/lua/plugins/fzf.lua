local fzf = require('fzf-lua')
local actions = require("fzf-lua").actions
fzf.setup({
    winopts = {
        -- split = "belowright new",-- open in a split instead?
        -- "belowright new"  : split below
        -- "aboveleft new"   : split above
        -- "belowright vnew" : split right
        -- "aboveleft vnew   : split left
        -- Only valid when using a float window
        -- (i.e. when 'split' is not defined, default)
        height        = 0.25, -- window height
        width         = 1, -- window width
        row           = 1, -- window row position (0=top, 1=bottom)
        col           = 0, -- window col position (0=left, 1=right)
        -- border argument passthrough to nvim_open_win()
        -- [ "/", "-", \"\\\\\", "|" ] ascci border:
        border        = "border-top",
        -- Backdrop opacity, 0 is fully opaque, 100 is fully transparent (i.e. disabled)
        backdrop      = 25,
        -- title         = "Title",
        -- title_pos     = "center",        -- 'left', 'center' or 'right'
        -- title_flags   = false,           -- uncomment to disable title flags
        fullscreen    = false, -- start fullscreen?
        -- enable treesitter highlighting for the main fzf window will only have
        -- effect where grep like results are present, i.e. "file:line:col:text"
        -- due to highlight color collisions will also override `fzf_colors`
        -- set `fzf_colors=false` or `fzf_colors.hl=...` to override
        treesitter    = {
            enabled    = true,
            fzf_colors = { ["hl"] = "-1:reverse", ["hl+"] = "-1:reverse" }
        },
        on_focus_lost = function()
            if fzf.win.is_open() then fzf.win.close() end
        end,
        preview       = {
            -- default     = 'bat',           -- override the default previewer?
            -- default uses the 'builtin' previewer
            border       = "rounded", -- preview border: accepts both `nvim_open_win`
            -- and fzf values (e.g. "border-top", "none")
            -- native fzf previewers (bat/cat/git/etc)
            -- can also be set to `fun(winopts, metadata)`
            wrap         = false, -- preview line wrap (fzf's 'wrap|nowrap')
            hidden       = false, -- start preview hidden
            vertical     = "down:45%", -- up|down:size
            horizontal   = "right:60%", -- right|left:size
            layout       = "flex", -- horizontal|vertical|flex
            flip_columns = 100, -- #cols to switch to horizontal on flex
            -- Only used with the builtin previewer:
            title        = true, -- preview border title (file/buf)?
            title_pos    = "center", -- left|center|right, title alignment
            scrollbar    = "float", -- `false` or string:'float|border'
            -- float:  in-window floating border
            -- border: in-border "block" marker
            scrolloff    = -1, -- float scrollbar offset from right
            -- applies only when scrollbar = 'float'
            delay        = 20, -- delay(ms) displaying the preview
            -- prevents lag on fast scrolling
            winopts      = { -- builtin previewer window options
                number         = true,
                relativenumber = false,
                cursorline     = true,
                cursorlineopt  = "both",
                cursorcolumn   = false,
                signcolumn     = "no",
                list           = false,
                foldenable     = false,
                foldmethod     = "manual",
            },
        },
        on_create     = function()
            -- called once upon creation of the fzf main window
            -- can be used to add custom fzf-lua mappings, e.g:
            --   vim.keymap.set("t", "<C-j>", "<Down>", { silent = true, buffer = true })
        end,
        -- called once _after_ the fzf interface is closed
        -- on_close = function() ... end
    },
    buffers = {
        previewer     = false,
        prompt        = 'Buffers❯ ',
        file_icons    = true, -- show file icons (true|"devicons"|"mini")?
        color_icons   = true, -- colorize file|git icons
        sort_lastused = true, -- sort buffers() by last used
        show_unloaded = true, -- show unloaded buffers
        cwd_only      = false, -- buffers for the cwd only
        cwd           = nil, -- buffers list for a given dir
        actions       = {
            -- actions inherit from 'actions.files' and merge
            -- by supplying a table of functions we're telling
            -- fzf-lua to not close the fzf window, this way we
            -- can resume the buffers picker on the same window
            -- eliminating an otherwise unaesthetic win "flash"
            ["ctrl-x"] = { fn = actions.buf_del, reload = true },
        }
    },
    keymap = {
        fzf = {
            ["ctrl-q"] = "select-all+accept",

        }
    },
    fzf_colors = {
        false, -- inherit fzf colors that aren't specified below from
        -- the auto-generated theme similar to `fzf_colors=true`
        ["fg"]      = { "fg", "CursorLine" },
        ["bg"]      = { "bg", "Normal" },
        ["hl"]      = { "fg", "Comment" },
        ["fg+"]     = { "fg", "Normal", "underline" },
        ["bg+"]     = { "bg", { "CursorLine", "Normal" } },
        ["hl+"]     = { "fg", "Normal" },
        ["info"]    = { "fg", "Normal" },
        ["prompt"]  = { "fg", "Conditional" },
        ["pointer"] = { "fg", "Exception" },
        ["marker"]  = { "fg", "Keyword" },
        ["spinner"] = { "fg", "Label" },
        ["header"]  = { "fg", "Comment" },
        ["gutter"]  = "-1",
    },
})

vim.api.nvim_create_autocmd("FocusLost", {
    callback = function()
        local w = require('fzf-lua.utils').fzf_winobj()
        if w then
            w:close()
        end
    end,
})




local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
local header_text = vim.api.nvim_get_hl(0, { name = "FzfLuaHeaderText", link = false })

vim.api.nvim_set_hl(0, "FzfLuaHeaderBind", { fg = header_text.fg, bold = true })
vim.api.nvim_set_hl(0, "FzfLuaLivePrompt", {fg = normal.fg})
vim.api.nvim_set_hl(0, "FzfLuaLiveSym",    {fg = normal.fg})


