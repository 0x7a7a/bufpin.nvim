---@class Pin
---@field fname string
---@field index integer
---@field wid integer
---@field bid integer
---@field show boolean
---@field padding integer
local Pin = {}
local webdevicons = require('nvim-web-devicons')

local function clone(obj)
  obj.destory = Pin.destory
  obj.make = Pin.make
  obj.update = Pin.update
  obj.set_index = Pin.set_index
  obj.get_win_opts = Pin.get_win_opts
  obj.pin = Pin.pin
  obj.unpin = Pin.unpin
end

---@return Pin
function Pin:new(index, fname)
  local obj = {
    show = true,
    index = index,
    fname = fname,
    bid = vim.api.nvim_create_buf(false, true),
    padding = 0,
  }

  clone(obj)
  obj:make()

  return obj
end

function Pin:destory()
  if self.bid then
    vim.api.nvim_buf_delete(self.bid, { force = true })
    self.bid = nil
  end

  if self.wid then
    vim.api.nvim_win_close(self.wid, true)
    self.wid = nil
  end
end

function Pin:make()
  local ext = vim.fn.fnamemodify(self.fname, ':e')
  local icon, _ = webdevicons.get_icon(self.fname, ext, { default = true })
  -- self.pin_text = string.format(' [%d] %s %s ', self.index, icon, self.fname)
  self.pin_text = string.format(' %s %s [%d] ', icon, self.fname, self.index)

  vim.api.nvim_buf_set_lines(self.bid, 0, -1, true, { self.pin_text })
  -- vim.api.nvim_buf_add_highlight(self.bid, -1, 'CursorLineNr', 0, 1, -1)
  -- vim.api.nvim_buf_add_highlight(self.bid, -1, hl_group, 0, #tostring(self.index) + 4, 7)
end

function Pin:update()
  self:make()
  if self.show then
    self:show()
  end
end

function Pin:set_index(index)
  self.index = index
  Pin:update()
end

function Pin:get_win_opts()
  -- width = #filename + ''#index_string + [](2) + padding(2) + icon(3)
  local width = #self.fname + #tostring(self.index) + 7
  -- local row = vim.o.lines - self.padding - (2 * self.index + 1)
  local row = self.padding + (2 * self.index + 1)
  local col = vim.o.columns - width

  return {
    style = 'minimal',
    relative = 'editor',
    focusable = false,
    height = 1,
    width = width,
    row = row,
    col = col,
  }
end

function Pin:pin()
  local wid = self.wid
  local opts = self:get_win_opts()

  if wid and vim.api.nvim_win_is_valid(wid) then
    vim.api.nvim_win_set_config(wid, opts)
    return
  end

  self.wid = vim.api.nvim_open_win(self.bid, false, opts)
  self.show = true
end

function Pin:unpin()
  if not self.show then
    return
  end

  local opts = self:get_win_opts()
  opts.hidden = true

  vim.api.nvim_win_set_config(self.wid, opts)
  self.show = false
end

return Pin
