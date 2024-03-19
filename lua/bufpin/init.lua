local Pin = require('bufpin.app')

local M = {}

M.setup = function(opts)
  opts = opts or {}

  M.pin = Pin:new(opts)

  M.pin:run()
end

return M
