local App = require('bufpin.app')

local M = {}

M.toggle = function()
  M.app:toggle()
end
M.show = function()
  M.app:show()
end
M.hide = function()
  M.app:hide()
end
M.refresh = function() end
M.pin = function() end
M.unpin = function() end
M.move_up = function() end
M.move_down = function() end
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
        show = true,
        show_num = 10,
        border = 'none',
      },
    }

  M.app = App:new(opts)
  M.app:run()
end

return M
