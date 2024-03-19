---@class Board
local Board = {}

---@return Board
function Board:new()
  self.padding = 0
  self.is_show = false
  return self
end

function Board:ishow()
  return self.is_show
end

-- TODO: if data is too long or opts.max_width limited
function Board:get_win_opts()
  local width = 20
  -- for _, txt in pairs(list) do
  --   if #txt > width then
  --     width = #txt
  --   end
  -- end
  local row = vim.o.lines / 2
  local col = vim.o.columns

  return {
    style = 'minimal',
    relative = 'editor',
    focusable = false,
    height = 10,
    width = width,
    row = row,
    col = col,
  }
end

function Board:show()
  if not self.wid or vim.api.nvim_win_is_valid(self.wid) then
    local opts = self:get_win_opts()
    self.wid = vim.api.nvim_open_win(self.bid, false, opts)
  end

  self.is_show = true
end

function Board:hide()
  if not self.wid or not self.is_show then
    return
  end

  local opts = vim.api.nvim_win_get_config(self.wid)
  opts.hide = true
  vim.api.nvim_win_set_config(self.wid, opts)

  self.is_show = false
end

function Board:render(list)
  if not self.bid or not vim.api.nvim_buf_is_valid(self.bid) then
    self.bid = vim.api.nvim_create_buf(false, true)
  end

  for _, info in pairs(list) do
    vim.api.nvim_buf_set_lines(self.bid, info.index, -1, true, { info.rank_txt })
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
