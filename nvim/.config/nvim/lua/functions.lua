local ts_utils = require("nvim-treesitter.ts_utils")


--  ╭─────────────────────────────────────────────────────────────────────────╮
--  │ Console Log Function                                                    │
--  ╰─────────────────────────────────────────────────────────────────────────╯
local function log_variable()
    local node = ts_utils.get_node_at_cursor()
    if not node then return end

    -- Find a variable-like node
    while node and not (
            node:type() == "identifier" or
            node:type() == "shorthand_property_identifier_pattern" or
            node:type() == "shorthand_property_identifier" or
            node:type() == "property_identifier"
        ) do
        node = node:parent()
    end
    if not node then return end

    local var_name = vim.treesitter.get_node_text(node, 0)

    -- Climb to the containing statement
    local stmt = node
    while stmt and stmt:type() ~= "variable_declarator" and stmt:type() ~= "lexical_declaration" do
        local parent = stmt:parent()
        if parent then
            stmt = parent
        else
            break
        end
    end
    if not stmt then return end

    -- Insert after statement
    local row = stmt:end_()                        -- 0-indexed end row
    vim.api.nvim_win_set_cursor(0, { row + 1, 0 }) -- move to next line
    vim.api.nvim_feedkeys("o" .. string.format('console.log("%s", %s);', var_name, var_name) .. "\027", "n", false)
end


--  ╭─────────────────────────────────────────────────────────────────────────╮
--  │ Comment Box                                                             │
--  ╰─────────────────────────────────────────────────────────────────────────╯
local function comment_box()
    local count = vim.v.count1

    local total_width = 79

    local tl, tr, bl, br = "╭", "╮", "╰", "╯"
    local horizontal, vertical = "─", "│"
    local comment_string = vim.bo.commentstring:gsub("%%s", " ")
    local line_num = vim.fn.line(".")

    local border_top = comment_string
        .. tl
        .. string.rep(horizontal, total_width - #comment_string - 2)
        .. tr
    local border_bottom = comment_string
        .. bl
        .. string.rep(horizontal, total_width - #comment_string - 2)
        .. br
    local text_lines = {}
    for _ = 1, count do
        local text = " "
        local padding =
            math.floor((total_width - #comment_string - 2 - #text) / 2)
        local text_line = comment_string
            .. vertical
            .. string.rep(" ", padding)
            .. text
            .. string.rep(
                " ",
                total_width - #comment_string - 2 - #text - padding
            )
            .. vertical
        table.insert(text_lines, text_line)
    end

    local content = { border_top }
    for _, line in ipairs(text_lines) do
        table.insert(content, line)
    end
    table.insert(content, border_bottom)

    vim.fn.append(line_num, content)

    local inner_start = #comment_string + 5
    vim.fn.cursor(line_num + 2, inner_start)
    vim.cmd([[startreplace]])
end


--  ╭─────────────────────────────────────────────────────────────────────────╮
--  │ Comment Line                                                            │
--  ╰─────────────────────────────────────────────────────────────────────────╯
local function comment_line()
    local line_num = vim.fn.line(".")
    local comment_string = vim.bo.commentstring:gsub("%%s", " ")
    local symbol = "─"

    local text = " "
    local padding = text:rep(6)
    vim.fn.append(line_num,
        comment_string .. symbol:rep(2) .. padding .. text .. symbol:rep(71 - #comment_string - 2))

    vim.fn.cursor(line_num + 1, #comment_string + 8)
    vim.cmd([[startreplace]])
end


--  ╭─────────────────────────────────────────────────────────────────────────╮
--  │ Buffer Delete while keeping window                                      │
--  ╰─────────────────────────────────────────────────────────────────────────╯

local function buffer_delete()
    local bufnr = vim.api.nvim_get_current_buf()

    -- Check if the current buffer state is dirty
    if vim.bo.modified then
        local choice = vim.fn.confirm("Buffer is modified. Save changes?", "&Yes\n&No\n&Cancel", 2)
        if choice == 1 then
            vim.cmd("write")
        elseif choice == 3 then
            return
        end
    end


    -- get all buffers sort by last used
    local buffers = vim.api.nvim_list_bufs()
    table.sort(buffers, function(a, b)
        return vim.fn.getbufinfo(a)[1].lastused > vim.fn.getbufinfo(b)[1].lastused
    end)


    -- if there is only one buffer, then just close it
    if #buffers == 1 then
        vim.cmd("enew")
        return
    end

    -- if there are more than one buffer, then delete current buffer
    -- and switch to the next one
    local next_bufnr = nil
    for _, buf in ipairs(buffers) do
        -- check if the buffer is a normal buffer
        if buf ~= bufnr and vim.api.nvim_buf_is_loaded(buf) and vim.fn.bufnr(buf) ~= -1 and vim.bo[buf].buflisted then
            next_bufnr = buf
            break
        end
    end
    if next_bufnr then
        vim.cmd("buffer " .. next_bufnr)
    else
        -- if there is no next buffer, then create a new one
        vim.cmd("enew")
    end



    vim.api.nvim_buf_delete(bufnr, { force = true })
end


--  ╭─────────────────────────────────────────────────────────────────────────╮
--  │ Zoom                                                                    │
--  ╰─────────────────────────────────────────────────────────────────────────╯


local focus_tab = nil
local focus_buf = nil

local function zoom()
    local current_tab = vim.api.nvim_get_current_tabpage()
    local current_win = vim.api.nvim_get_current_win()
    local current_buf = vim.api.nvim_win_get_buf(current_win)

    -- If we are already in focus mode, close the tab
    if focus_tab and vim.api.nvim_tabpage_is_valid(focus_tab) and focus_tab == current_tab then
        vim.api.nvim_command("tabclose")
        return

        -- if we are in a different tab, reset focus_tab and focus_buf
    elseif focus_tab and vim.api.nvim_tabpage_is_valid(focus_tab) and focus_tab ~= current_tab then
        --close the previous focus tab if it exists
        if vim.api.nvim_tabpage_is_valid(focus_tab) then
            vim.api.nvim_command("tabclose " .. tostring(focus_tab))
        end

        focus_tab = nil
        focus_buf = nil
    end


    focus_buf = current_buf

    vim.cmd("tabnew")

    focus_tab = vim.api.nvim_get_current_tabpage()
    current_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(current_win, focus_buf)

    local width = vim.api.nvim_win_get_width(current_win)
    local padding_width = math.floor(width * 0.25)
    local note_buf = "edit ~/notes.md"


    -- Add left split
    vim.cmd("topleft vnew")
    local left = vim.api.nvim_get_current_win()
    vim.cmd(note_buf)
    vim.api.nvim_win_set_width(left, padding_width)

    -- Go back to middle
    vim.api.nvim_set_current_win(current_win)

    -- Add right split
    vim.cmd("botright vnew")
    local right = vim.api.nvim_get_current_win()
    vim.cmd(note_buf)
    vim.api.nvim_win_set_width(right, padding_width)

    -- Focus middle
    vim.api.nvim_set_current_win(current_win)
end




--  ╭─────────────────────────────────────────────────────────────────────────╮
--  │ auto commands                                                           │
--  ╰─────────────────────────────────────────────────────────────────────────╯
local augroup = vim.api.nvim_create_augroup("UserConfig", {})

vim.api.nvim_create_autocmd("VimResized", {
    group = augroup,
    callback = function()
        vim.cmd("tabdo wincmd =")
    end
})

-- Remove items from quickfix list.
-- `dd` to delete in Normal
-- `d` to delete Visual selection
-- https://github.com/rmarganti/.dotfiles/blob/main/dots/.config/nvim/lua/rmarganti/core/autocommands.lua#L5
local function delete_qf_items()
    local mode = vim.api.nvim_get_mode()['mode']

    local start_idx
    local count

    if mode == 'n' then
        -- Normal mode
        start_idx = vim.fn.line('.')
        count = vim.v.count > 0 and vim.v.count or 1
    else
        -- Visual mode
        local v_start_idx = vim.fn.line('v')
        local v_end_idx = vim.fn.line('.')

        start_idx = math.min(v_start_idx, v_end_idx)
        count = math.abs(v_end_idx - v_start_idx) + 1

        -- Go back to normal
        vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes(
                '<esc>', -- what to escape
                true,    -- Vim leftovers
                false,   -- Also replace `<lt>`?
                true     -- Replace keycodes (like `<esc>`)?
            ),
            'x',         -- Mode flag
            false        -- Should be false, since we already `nvim_replace_termcodes()`
        )
    end

    local qflist = vim.fn.getqflist()

    for _ = 1, count, 1 do
        table.remove(qflist, start_idx)
    end

    vim.fn.setqflist(qflist, 'r')
    vim.fn.cursor(start_idx, 1)
end

vim.api.nvim_create_autocmd('FileType', {
    group = augroup,
    pattern = 'qf',
    callback = function()
        -- Escape closes quickfix window.
        vim.keymap.set(
            'n',
            '<ESC>',
            '<CMD>cclose<CR>',
            { buffer = true, remap = false, silent = true }
        )

        -- `dd` deletes an item from the list.
        vim.keymap.set('n', 'dd', delete_qf_items, { buffer = true })
        vim.keymap.set('x', 'd', delete_qf_items, { buffer = true })
    end,
    desc = 'Quickfix tweaks',
})

vim.api.nvim_create_autocmd('TextYankPost', {
    group = augroup,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'Visual',
            timeout = 200,
        })
    end,
    desc = 'Highlight on yank',
})

vim.api.nvim_create_autocmd('BufEnter', {
    group = augroup,
    callback = function(args)
        local lines = vim.api.nvim_buf_line_count(args.buf)
        if lines > 10 then
            vim.o.scroll = 10
        end
    end,
    desc = "Set scroll size to 10 on buffer enter",
})
vim.api.nvim_create_autocmd("FileType", {
    pattern = "typescript,typescriptreact",
    group = augroup,
    command = "compiler tsc | setlocal makeprg=cd\\ ./apps/web\\ &&\\ bun\\ run\\ build:check:clean",
})

return {
    log_variable = log_variable,
    comment_box = comment_box,
    comment_line = comment_line,
    buffer_delete = buffer_delete,
    zoom = zoom,
}
