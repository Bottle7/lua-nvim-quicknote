local note = require("lua-nvim-quicknote.note")
local window = require("lua-nvim-quicknote.window")

local function create_commands()
  vim.api.nvim_create_user_command("QuickNoteToggle", function()
    window.toggle_note_window()
  end, {})

  vim.api.nvim_create_user_command("QuickNoteSave", function()
    note.save_note()
  end, {})

  vim.api.nvim_create_user_command('QuickNoteConfig', function(opts)
    if opts.args == 'dir' then
      print('Current notes directory: ' .. note.get_config_dir())
    elseif opts.args:match('^dir%s+') then
      local new_dir = opts.args:match('^dir%s+(.+)')
      note.set_config_dir(new_dir)
      print('Notes directory set to: ' .. note.get_config_dir())
    else
      print('Usage: QuickNoteConfig dir [path]')
    end
  end, {nargs = '*', complete = function(_, _, _)
    return {'dir'}
  end})
end

local function setup(user_config)
  note.setup(user_config)
  create_commands()
end

return {
  setup = setup
}
