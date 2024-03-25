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

local default_opts = {
  rank = {
    num = 10,
  },
  storage = {
    dir = vim.fn.stdpath('cache') .. '/bufpin/',
    git_branch = true,
  },
  board = {
    mode = 'follow', -- follow or fixed
    pin_icon = '󰐃',
    border = 'none', -- single / double / rounder /none
    max_filename = 20,
    -- border_height is automatically calculated based on the displayed content.
    float_height = function(border_height)
      -- the default is vertical-center
      local win_height = vim.fn.winheight(0)
      return math.floor((win_height - border_height) / 2)
    end,
  },
  ignore_ft = {
    'help',
    'http',
    'mason',
    'neotest-summary',
  },
}

-- TODO: A Config class may be required
M.setup = function(opts)
  opts = opts or {}
  opts = vim.tbl_deep_extend('keep', opts, default_opts)

  M.app = App:new(opts)
  M.app:run()
end

return M
