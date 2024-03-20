local App = require('bufpin.app')

local M = {}

M.toggle = function()
  M.app:toggle()
end
M.toggle_pin = function()
  M.app:toggle_pin()
end
M.remove = function() end
M.clear = function() end
M.prev = function() end
M.next = function() end
M.go_to = function(index)
  M.app:go_to(index)
end

M.setup = function(opts)
  opts = opts
    or {
      ignore_ft = {
        'help',
      },
      board = {
        pin_icon = '󰐃',
        show = true,
        show_num = 10,
        border = 'none',
      },
    }

  M.app = App:new(opts)
  M.app:run()
end

return M
