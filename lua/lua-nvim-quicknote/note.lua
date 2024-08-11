local api = vim.api
local fn = vim.fn

local M = {}

-- Configuration
local config = {
  notes_dir = fn.expand('~/notes'),
}

local config_file = fn.stdpath('config') .. '/quicknote_config.json'

local function expand_path(path)
  if path:sub(1,1) == '~' then
    local home = os.getenv("HOME") or os.getenv("USERPROFILE")
    return home .. path:sub(2)
  end
  return path
end

local function save_config()
  local json = fn.json_encode(config)
  fn.writefile({json}, config_file)
end

local function load_config()
  if fn.filereadable(config_file) == 1 then
    local json = fn.readfile(config_file)[1]
    local loaded_config = fn.json_decode(json)
    if type(loaded_config) == 'table' then
      config = vim.tbl_deep_extend("force", config, loaded_config)
    end
  end
end

local function sanitize_filename(name)
  name = name.gsub('[^%w%s%-]', '_')
  name = name:gsub('%s+', '_')
  name = name:gsub('^_+', ''):gsub('_+$', '')
  return name
end

function M.setup(user_config)
  load_config()
  config = vim.tbl_deep_extend("force", config, user_config or {})
  config.notes_dir = expand_path(config.notes_dir)
  fn.mkdir(config.notes_dir, 'p')
  save_config()
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

  local first_line = lines[1] or ""
  local filename = first_line:sub(1, 30)
  filename = sanitize_filename(filename)

  if filename == "" then
    filename = os.date('%Y-%m-%d_%H_%M-%S')
  end

  filename = filename .. ".md"

  local filepath = fn.resolve(config.notes_dir .. '/' .. filename)

  fn.writefile(lines, filepath)
  print('Note saved: ' .. filepath)
end

return M
