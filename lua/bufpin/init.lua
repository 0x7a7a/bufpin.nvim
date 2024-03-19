local App = require('bufpin.app')

local M = {}

M.setup = function(opts)
  opts = {
    show_board = true,
  }

  M.app = App:new(opts)

  M.app:run()
end

return M
