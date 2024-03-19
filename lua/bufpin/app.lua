local Pin = require('bufpin.pin')
local Config = require('bufpin.config')
local Storage = require('bufpin.storage')

---@class pin.app
---@field cur_win integer
---@field win_id integer
---@field buf_id integer
---@field show boolean
local App = {
  show = false,
  pins = {},
}

function App:new(opts)
  self.conf = Config:new(opts)
  self.storage = Storage:new()

  return self
end

function App:render()
  local pin_list = self.storage:get_all()

  for index, fname in pairs(pin_list) do
    local pin = Pin:new(index, fname)

    if self.conf:get('show') or true then
      pin:pin()
    end

    table.insert(self.pins, pin)
  end

  self.show = true
  vim.api.nvim_create_augroup('AutoPin', { clear = true })
  -- vim.api.nvim_create_autocmd('WinClosed', {
  --   group = 'AutoPin',
  --   callback = function()
  --     print(123)
  --     self:render()
  --   end,
  -- })
end

function App:run()
  -- self:render()
end

return App
