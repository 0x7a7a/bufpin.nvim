local Board = {}

function Board:new(opts)
  return setmetatable({
    opts = opts,
    is_show = false,
  }, { __index = self })
end

function Board:ishow()
  return self.is_show
end

-- TODO: the width should be more flexible when secondary directories
function Board:get_win_opts()
  local row = vim.o.lines / 2 - 20
  local col = vim.o.columns

  return {
    style = 'minimal',
    relative = 'editor',
    focusable = false,
    width = 25,
    height = 12,
    row = row,
    col = col,
    border = self.opts.border,
  }
end

function Board:show()
  if not self.wid or not vim.api.nvim_win_is_valid(self.wid) then
    self.is_show = true
    local opts = self:get_win_opts()
    self.wid = vim.api.nvim_open_win(self.bid, false, opts)
    return
  end

  if self.is_show then
    return
  end
  self.is_show = true

  local opts = vim.api.nvim_win_get_config(self.wid)
  opts.hide = false
  vim.api.nvim_win_set_config(self.wid, opts)
end

function Board:hide()
  if not self.wid or not self.is_show or not vim.api.nvim_win_is_valid(self.wid) then
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
