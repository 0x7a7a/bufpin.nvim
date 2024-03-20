local App = require('bufpin.app')

local M = {}

M.toggle = function()
  M.app:toggle()
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

M.prev = function()
  M.app:prev()
end

M.next = function()
  M.app:next()
end

M.go_to = function(index)
  M.app:go_to(index)
end

M.setup = function(opts)
  opts = {
    -- TODO
    ignore_ft = {
      'help',
    },
    rank = {
      topn = 10,
    },
    storage = {
      dir = vim.fn.stdpath('cache'),
      git_branch = false,
    },
    board = {
      pin_icon = '󰐃',
      show = true,
      border = 'none',
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
