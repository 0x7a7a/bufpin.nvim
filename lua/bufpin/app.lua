local utils = require('bufpin.utils')

local App = {}

function App:new(opts)
  local Rank = require('bufpin.rank')
  local Board = require('bufpin.board')
  local Storage = require('bufpin.storage')

  local storage = Storage:new(opts.storage)
  local rank = Rank:new(opts.rank, storage)
  local board = Board:new(opts.rank)

  return setmetatable({
    opts = opts,
    rank = rank,
    board = board,
  }, { __index = self })
end

function App:ignore_ft(ftype)
  for _, ft in pairs(self.opts.ignore_ft) do
    if ftype == ft then
      return true
    end
  end

  return false
end

function App:data_init()
  self.rank_list = self.rank:init()
end

function App:start_monitor_bufs()
  if self.augroup_id and self.aucmd_id then
    return
  end

  local gid = vim.api.nvim_create_augroup('BufPin', {})
  local cid = vim.api.nvim_create_autocmd({ 'BufEnter', 'BufLeave' }, {
    group = gid,
    callback = function(args)
      local event = args.event
      local fname = args.file
      local ftype = vim.o.filetype

      if self:ignore_ft(ftype) then
        return
      end

      if event == 'BufEnter' then
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
    local icon, hl_icon = utils.get_icon(fname)
    local hls = {}

    local prefix = file.pinned and self.opts.board.pin_icon or tostring(index)
    local rank_txt = string.format(' [%s] %s %s ', prefix, icon, fname)

    if utils.get_current_filepath() == file.path then
      local hl_cur = {
        hl_group = 'CursorLineNr',
        col_start = 0,
        col_end = -1,
      }
      table.insert(hls, hl_cur)
    end
    -- FIX: testing icon in kitty affects highlighting
    -- table.insert(hls, { hl_group = hl_icon, col_start = 5, col_end = 8 })

    table.insert(board_list, {
      index = index,
      rank_txt = rank_txt,
      hls = hls,
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

function App:toggle()
  if self.board:ishow() then
    self:hide()
  else
    self:show()
  end
end

function App:go_to(index)
  local file = App.rank:get_file(index)
  if file ~= nil then
    vim.cmd(':edit ' .. file.path)
  end
end

function App:toggle_pin()
  self.rank:toggle_pin()
  self:render()
end

function App:remove()
  self.rank:remove()
  self:render()
end

function App:remove_all()
  self.rank:remove_all()
  self:render()
end

function App:prev()
  local index = self.rank:get_file_index()
  local last = self.rank:count()
  if index == 1 then
    index = last
  else
    index = index - 1
  end

  self:go_to(index)
end

function App:next()
  local index = self.rank:get_file_index()
  local last = self.rank:count()
  if index == last then
    index = 1
  else
    index = index + 1
  end

  self:go_to(index)
end

function App:run()
  self:data_init()
  self:start_monitor_bufs()

  if self.opts.board.show then
    self:render()
    self:show()
  end
end

return App
