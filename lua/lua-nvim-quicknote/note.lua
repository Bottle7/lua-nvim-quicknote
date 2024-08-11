local api = vim.api
local fn = vim.fn

local M = {}

-- Configuration
local config = {
  notes_dir = fn.expand('~/notes'),
}

local function get_title_as_filename()
    local first_line = fn.getline(1)
    local sanitized_title = first_line:gsub("%s+", "_"):gsub("[^%w_]", "")
    return sanitized_title:sub(1, 30) -- Limit to 30 characters
end

function M.setup(user_config)
  config = vim.tbl_deep_extend("force", config, user_config or {})
  fn.mkdir(config.notes_dir, 'p')
end

-- Find out where the notes are being saved
function M.get_config_dir()
  return config.notes_dir
end

-- Set the where notes are saved
function M.set_config_dir(dir)
  config.notes_dir = fn.expand(dir)
  fn.mkdir(config.notes_dir, 'p')
end

-- Create a buffer for the note
function M.create_note_buffer()
  local buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_option(buf, 'filetype', 'markdown')
  return buf
end

-- Save the note
function M.save_note(buf)
  buf = buf or api.nvim_get_current_buf()
  local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
  local filename = get_title_as_filename() .. ".md"
  local filepath = fn.resolve(config.notes_dir .. '/' .. filename)
  fn.writefile(lines, filepath)
  print('Note saved: ' .. filepath)
end

return M
