vim.g.mapleader = " "
-- vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<leader>pv", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- move text blocks w/ J/K
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- replace paste
vim.keymap.set("x", "<leader>p", [["_dP]])
vim.keymap.set("x", "D", '"_d', { desc = "Delete without yanking" })

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

vim.keymap.set("n", "Q", "<nop>")

-- vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
-- vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>l", "iconsole.log(<C-r>=expand('<cword>')<CR>)<Esc>F(a")
-- vim.keymap.set("n", "<leader>m", "<cmd>lnext<CR>zz")
-- vim.keymap.set("n", "<leader>n", "<cmd>lprev<CR>zz")
vim.keymap.set("n", "<leader>c", "<cmd>lclose<CR><cmd>cclose<CR>zz")
vim.keymap.set("n", "<leader>q", "<cmd>copen<CR>zz")
vim.keymap.set("n", "<leader>Q", "<cmd>cclose<CR>zz")

vim.keymap.set("n", "<leader>k", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<leader>K", "<cmd>lprev<CR>zz")
vim.keymap.set("n", "<leader>J", "<cmd>lnext<CR>zz")

-- spider movement
vim.keymap.set(
    { "n", "o", "x" },
    "<M-w>",
    "<cmd>lua require('spider').motion('w')<CR>",
    { desc = "Spider-w" }
)
vim.keymap.set(
    { "n", "o", "x" },
    "<M-e>",
    "<cmd>lua require('spider').motion('e')<CR>",
    { desc = "Spider-e" }
)
vim.keymap.set(
    { "n", "o", "x" },
    "<M-b>",
    "<cmd>lua require('spider').motion('b')<CR>",
    { desc = "Spider-b" }
)

vim.keymap.set("n", "<Leader>ff", function()
    vim.lsp.buf.format({ bufnr = vim.api.nvim_get_current_buf() })
end, { buffer = bufnr, desc = "[lsp] format" })


vim.keymap.set("n", "<leader>gh", "<cmd>0GlLog<CR>")

vim.keymap.set("n", "<leader>d", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
end)

-- map CTRL+V to instert literal escapes in insert mode: <C-v><Esc>
-- vim.keymap.set({ "i" }, "<C-x>", "<C-v>", { noremap = true, silent = true })

vim.keymap.set({ "n", "i", "v" }, "<C-s>", "<ESC>:Prettier<CR>:w<CR>")
-- vim.keymap.set({ "n", "i", "v" }, "<C-s>", "<ESC>:Prettier<CR>:w<CR>:NeomakeProject<CR>")

vim.cmd([[:call setreg("o", "F\"vf\"S{wvf\"S(iclsxwa{},bla")
nmap <M-d> @o]])

-- vim.keymap.set("n", "<leader>l", "iconsole.log(<C-r>=expand('<cword>')<CR>)<Esc>F(a")
vim.keymap.set("n", "<leader>l", "yiwoconsole.log(<Esc>pa)<Esc>F(ea")



-- vim.keymap.set("n", "<C-1>", "<C-^>")
--this doesnt work instead:
vim.cmd([[
]])


-- Commands explained:
-- :t''<CR> - copy current line to new line below
-- :T''<CR> - copy current line to new line above
-- :m''<CR> - move current line to new line below
-- :M''<CR> - move current line to new line above
-- :d<CR>`` - delete current line and return to original cursor position

vim.cmd([[
cnoremap $t <CR>:t''<CR>
cnoremap $T <CR>:T''<CR>
cnoremap $m <CR>:m''<CR>
cnoremap $M <CR>:M''<CR>
cnoremap $d <CR>:d<CR>``
]])

vim.keymap.set("n", "<leader>r", "<cmd>%bd|e#<cr>", { desc = "Close all buffers but the current one" })

-- toggle wordwrap keybind on leader w
vim.keymap.set("n", "<leader>w", function()
    vim.wo.wrap = not vim.wo.wrap
end)


vim.keymap.set('n', '<leader>S', '<cmd>lua require("spectre").toggle()<CR>', {
    desc = "Toggle Spectre"
})
vim.keymap.set('n', '<leader>sw', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
    desc = "Search current word"
})
vim.keymap.set('v', '<leader>sw', '<esc><cmd>lua require("spectre").open_visual()<CR>', {
    desc = "Search current word"
})
vim.keymap.set('n', '<leader>sf', '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
    desc = "Search on current file"
})

--  nnoremap <expr> j v:count ? 'j' : 'gj'
-- nnoremap <expr> k v:count ? 'k' : 'gk'
vim.keymap.set("n", "j", "v:count ? 'j' : 'gj'", { expr = true })
vim.keymap.set("n", "k", "v:count ? 'k' : 'gk'", { expr = true })

-- vim.keymap.set("n", "<leader>e",  function () vim.diagnostic.jump({count= 1,float = true}) end, { desc = "Jump to next diagnostic" })
-- vim.keymap.set("n", "<leader>E", vim.diagnostic.goto_prev)
vim.diagnostic.config({ jump = { float = true } })

vim.keymap.set('s', '<S-j>', 'j', { noremap = true })
vim.keymap.set('s', '<S-k>', 'k', { noremap = true })
vim.keymap.set('s', '<S-h>', 'h', { noremap = true })
vim.keymap.set('s', '<S-l>', 'l', { noremap = true })




local ts_utils = require("nvim-treesitter.ts_utils")

function JumpToHtmlTagEnd()
    local node = ts_utils.get_node_at_cursor()
    if not node then return end

    -- Climb to the parent tag node
    while node do
        local t = node:type()
        print(t)
        if t == "jsx_opening_element" or t == "jsx_closing_element" or t == "jsx_self_closing_element" then
            break
        end
        node = node:parent()
    end

    if not node then
        -- print("Not in an HTML tag")
        return
    end

    -- Jump to end of node
    local _, _, end_row, end_col = node:range()
    vim.api.nvim_win_set_cursor(0, { end_row + 1, end_col })
end

vim.keymap.set('n', 't%', JumpToHtmlTagEnd, { desc = "Treesitter HTML tag jump" })



-- function SendLspCommand(command, args)
--     local params = {
--         command = command,
--         arguments = args or {},
--         title = ""
--     }
--     vim.lsp.buf.execute_command(params)
-- end


vim.keymap.set("n", "<leader>li", require('icons.icon-picker').pick, { desc = "Pick Lucide Icon" })






-- Define inner text object for backticks (`) using Lua
function _G.select_backtick_textobject_2(inner)
  local line = vim.fn.getline('.')
  local col = vim.fn.col('.')
  local start, finish

  -- Search backwards for ` or ' or "
  for i = col - 1, 1, -1 do
    if line:sub(i, i) == '`' or line:sub(i, i) == "'" or line:sub(i, i) == '"' then
      start = i
      break
    end
  end

  -- Search forwards for ` or '
  for i = col, #line do
    if line:sub(i, i) == '`' or line:sub(i, i) == "'" or line:sub(i, i) == '"' then
      finish = i - 1
      break
    end
  end

  if start and finish and start < finish then
    if inner then
      vim.fn.setpos("'<", {0, vim.fn.line('.'), start + 1, 0})
      vim.fn.setpos("'>", {0, vim.fn.line('.'), finish, 0})
    else
      vim.fn.setpos("'<", {0, vim.fn.line('.'), start, 0})
      vim.fn.setpos("'>", {0, vim.fn.line('.'), finish + 1, 0})
    end
    vim.cmd('normal! gv')
  end
end

-- Map iq and aq
vim.keymap.set({'o', 'x'}, 'iq', function() select_backtick_textobject_2(true) end, { noremap = true, silent = true })
vim.keymap.set({'o', 'x'}, 'aq', function() select_backtick_textobject_2(false) end, { noremap = true, silent = true })


-- cgn for last replaced word
vim.keymap.set("n", "g.", [[/\V\C<C-r>"<CR>cgn<C-a><Esc>]], { noremap = true, silent = true })
