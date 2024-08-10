local api = vim.api
local note = require("lua-nvim-quicknote.note")

local M = {}

local note_win = nil
local note_buf = nil

-- Create a floating window
local function create_float_win()
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local buf = note.create_note_buffer()

  local opts = {
    relative = 'editor',
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = 'minimal',
    border = 'rounded',
  }

  local win = api.nvim_open_win(buf, true, opts)
  return win, buf
end

function M.toggle_note_window()
  if note_win and api.nvim_win_is_valid(note_win) then
    api.nvim_win_close(note_win, true)
    note.save_note(note_buf)
    note_win = nil
    note_buf = nil
  else
    note_win, note_buf = create_float_win()
  end
end

return M
