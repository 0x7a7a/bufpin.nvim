local App = require('bufpin.app')

local M = {}

M.toggle = function()
  M.app:toggle()
end

M.close = function()
  M.app:close()
end

M.toggle_pin = function()
  M.app:toggle_pin()
end

M.remove = function()
  M.app:remove()
end

M.remove_all = function()
  M.app:remove_all()
end

M.prev_pinned = function()
  M.app:prev_pinned()
end

M.next_pinned = function()
  M.app:next_pinned()
end

M.go_to = function(index)
  M.app:go_to(index)
end

M.setup = function(opts)
  opts = {
    -- TODO
    ignore_ft = {
      'help',
      'http',
      'neotest-summary',
    },
    rank = {
      topn = 10,
    },
    storage = {
      dir = vim.fn.stdpath('cache') .. '/bufpin/',
      git_branch = true,
    },
    board = {
      pin_icon = '󰐃',
      show = false,
      border = 'none',
      max_filename = 20,
      -- TODO
      show_time = 'aways', -- aways or buf_enter
      -- TODO
      keep_alive = false,
    },
  }

  M.app = App:new(opts)
  M.app:run()
end

return M
