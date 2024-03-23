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

-- TODO: A Config class may be required
M.setup = function(opts)
  opts = {
    rank = {
      topn = 10,
    },
    storage = {
      dir = vim.fn.stdpath('cache') .. '/bufpin/',
      git_branch = true,
    },
    board = {
      mode = 'follow', -- follow or fixed
      pin_icon = '󰐃',
      border = 'none',
      max_filename = 20,
    },
    ignore_ft = {
      'help',
      'http',
      'mason',
      'neotest-summary',
    },
  }

  M.app = App:new(opts)
  M.app:run()
end

return M
