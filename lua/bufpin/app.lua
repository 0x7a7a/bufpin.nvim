local Rank = require('bufpin.rank')
local Board = require('bufpin.board')
local utils = require('bufpin.utils')

---@class pin.app
---@field cur_win integer
---@field win_id integer
---@field buf_id integer
local App = {
  rank_list = {},
  pins = {},
}

function App:new(opts)
  self.opts = opts
  self.rank = Rank:new(10)
  self.board = Board:new()

  return self
end

function App:ignore_ft(ftype)
  return false
end

function App:data_init()
  self.rank_list = self.rank:init()
end

function App:start_monitor_bufs()
  if self.dev then
    vim.api.nvim_del_autocmd(self.aucmd_id)
    self.aucmd_id = nil
  end
  if self.augroup_id and self.aucmd_id then
    return
  end

  local gid = vim.api.nvim_create_augroup('BufPin', {})
  local cid = vim.api.nvim_create_autocmd({ 'BufEnter', 'BufLeave' }, {
    group = gid,
    callback = function(args)
      local event = args.event
      local fname = args.file

      if event == 'BufEnter' then
        if self:ignore_ft(fname) then
          return
        end
        self.rank:rise(fname)
        self:render()
      end
      if event == 'BufLeave' then
        self.rank:down()
        self:render()
      end
      -- TODO: if app window is closed
      -- if event == 'WinClosed' then
      -- end

      -- vim.notify(vim.inspect(self.rank:raw()))
    end,
  })

  self.augroup_id = gid
  self.aucmd_id = cid
end

function App:get_board_list()
  local rank_list = self.rank:raw()
  local board_list = {}

  for index, file in pairs(rank_list) do
    local fname = utils.get_file_name(file.path)
    local icon, hl_group = utils.get_icon(fname)
    local rank_txt = string.format(' [%d] %s %s ', index, icon, fname)

    table.insert(board_list, {
      index = index,
      rank_txt = rank_txt,
      hl_group = hl_group,
    })
  end

  return board_list
end

function App:render()
  local board_list = self:get_board_list()
  self.board:render(board_list)
end

function App:show()
  self.board:show()
end

function App:hide()
  self.board:hide()
end

function App:toogle()
  if self.board:ishow() then
    self:hide()
  else
    self:hide()
  end
end

function App:run()
  self:data_init()
  self:start_monitor_bufs()

  if self.opts.show_board then
    self:render()
    self:show()
  end

  self.dev = true
end

return App
