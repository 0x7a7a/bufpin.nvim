local utils = require('bufpin.utils')
local Board = {}

function Board:new(opts)
  return setmetatable({
    opts = opts,
    is_show = false,
    width = 0,
    height = 0,
  }, { __index = self })
end

function Board:set_width(width)
  self.width = width + 8
end

function Board:set_height(height)
  self.height = height + 2
end

function Board:ishow()
  return self.is_show
end

function Board:is_folow_mode()
  return self.opts.mode == 'follow'
end

function Board:get_win_opts()
  local col = vim.o.columns - self.width
  if self:is_folow_mode() then
    col = vim.fn.winwidth(0) - self.width
  end

  local border = self.opts.border
  if border ~= 'none' and border ~= nil then
    col = col - 2
  end

  local row, ok
  local opts_height = self.opts.float_height
  if type(opts_height) == 'number' then
    row = opts_height
  end

  if type(opts_height) == 'function' then
    local func = self.opts.float_height
    ok, row = pcall(func, self.height)
  end
  if not ok or row == nil then
    utils.notify('call float_height function err,use default option')
    local win_height = vim.fn.winheight(0)
    row = math.floor((win_height - self.height) / 2)
  end

  local opts = {
    style = 'minimal',
    relative = 'editor',
    focusable = false,
    width = self.width,
    height = self.height,
    row = row,
    col = col,
    border = border,
  }

  if self:is_folow_mode() then
    opts.relative = 'win'
    opts.win = 0
  end

  return opts
end

function Board:reset_win()
  if not self:ishow() or not self:win_exist() then
    return
  end

  local opts = self:get_win_opts()
  vim.api.nvim_win_set_config(self.wid, opts)
end

function Board:win_exist()
  return self.wid and vim.api.nvim_win_is_valid(self.wid)
end

function Board:show()
  if not self:win_exist() then
    self.is_show = true
    local opts = self:get_win_opts()
    self.wid = vim.api.nvim_open_win(self.bid, false, opts)
    vim.api.nvim_set_option_value('wrap', false, { win = self.wid })
    return
  end

  if self:ishow() then
    return
  end

  self.is_show = true

  local opts = self:get_win_opts()
  opts.hide = false
  vim.api.nvim_win_set_config(self.wid, opts)
end

function Board:hide()
  if not self:ishow() or not self:win_exist() then
    self.is_show = false
    return
  end

  self.is_show = false

  local opts = vim.api.nvim_win_get_config(self.wid)
  opts.hide = true
  vim.api.nvim_win_set_config(self.wid, opts)
end

function Board:render(list)
  if not self.bid or not vim.api.nvim_buf_is_valid(self.bid) then
    self.bid = vim.api.nvim_create_buf(false, true)
  end

  for _, info in pairs(list) do
    vim.api.nvim_buf_set_lines(self.bid, info.index, -1, true, { info.rank_txt })
    for _, hl in pairs(info.hls) do
      vim.api.nvim_buf_add_highlight(self.bid, -1, hl.hl_group, info.index, hl.col_start, hl.col_end)
    end
  end

  if #list == 0 then
    local empty = ' BufPin is empty '
    vim.api.nvim_buf_set_lines(self.bid, 1, -1, true, { empty })
    self.width = #empty
    self.height = 3
  end

  if self:is_folow_mode() then
    self:reset_win()
  end
end

function Board:destory()
  if self.bid then
    vim.api.nvim_buf_delete(self.bid, { force = true })
    self.bid = nil
  end

  if self.wid then
    vim.api.nvim_win_close(self.wid, true)
    self.wid = nil
  end
end

return Board
