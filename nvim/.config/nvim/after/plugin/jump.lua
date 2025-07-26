-- lua/filejump.lua
local M = {
  stack = {},
  index = 0,
}

function M.should_track(buf)
  if not vim.api.nvim_buf_is_valid(buf) then return false end
  if not vim.api.nvim_buf_is_loaded(buf) then return false end

  local bt = vim.bo[buf].buftype
  if bt ~= "" then return false end

  local ft = vim.bo[buf].filetype
  if ft == "oil" then return false end  -- ignore oil.nvim

  return true
end

function M.track_jump(args)
  local buf = args.buf
  if not M.should_track(buf) then return end

  -- avoid duplicates
  local last = M.stack[M.index]
  if last and last.buf == buf then return end

  -- trim forward history
  while #M.stack > M.index do
    table.remove(M.stack)
  end

  local pos = vim.api.nvim_win_get_cursor(0)
  table.insert(M.stack, { buf = buf, lnum = pos[1], col = pos[2] })
  M.index = #M.stack
end

function M.jump(step)
  local new_index = M.index + step
  if new_index < 1 or new_index > #M.stack then
    vim.notify("No more file jumps in this direction", vim.log.levels.INFO)
    return
  end

  local entry = M.stack[new_index]
  if vim.api.nvim_buf_is_loaded(entry.buf) then
    vim.api.nvim_set_current_buf(entry.buf)
    vim.api.nvim_win_set_cursor(0, { entry.lnum, entry.col })
    M.index = new_index
  end
end

function M.setup()
  vim.api.nvim_create_autocmd("BufLeave", {
    callback = M.track_jump,
  })
end



M.setup()

vim.keymap.set("n", "<C-l>", function()
    M.jump(1)
end, { desc = "Jump to next file in jumplist" })
vim.keymap.set("n", "<C-h>", function()
    M.jump(-1)
end, { desc = "Jump to previous file in jumplist" })
