local utils = require('bufpin.utils')

local App = {}

function App:new(opts)
  local Rank = require('bufpin.rank')
  local Board = require('bufpin.board')
  local Storage = require('bufpin.storage')

  local storage = Storage:new(opts.storage)
  local rank = Rank:new(opts.rank, storage)
  local board = Board:new(opts.board)

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
  local cid = vim.api.nvim_create_autocmd({ 'BufEnter', 'InsertLeave', 'BufWritePost' }, {
    group = gid,
    callback = function(args)
      local event = args.event
      local fname = args.file
      local ftype = vim.o.filetype

      if self:ignore_ft(ftype) then
        return
      end

      if #fname == 0 then
        return
      end

      if event == 'BufWritePost' or event == 'InsertLeave' then
        if self.board:ishow() then
          self:render()
        end
      end

      if event == 'BufEnter' then
        self.rank:rise(fname)
        if self.board:ishow() then
          self:render()
        end
      end
    end,
  })

  self.augroup_id = gid
  self.aucmd_id = cid
end

function App:get_board_list()
  local rank_list = self.rank:raw()
  local board_list = {}
  local max_fname_len = 0

  --check files with same name
  local unique_set = {}
  local unique_res = {}
  for _, v in pairs(rank_list) do
    local fname = utils.get_file_name(v.path)
    if not unique_set[fname] then
      unique_set[fname] = true
    else
      unique_res[fname] = true
    end
  end

  local unsaved_files = {}
  for _, buf in pairs(vim.fn.getbufinfo({ buflisted = 1 })) do
    if buf.changed == 1 then
      unsaved_files[buf.name] = true
    end
  end

  for index, file in pairs(rank_list) do
    local fname = utils.get_file_name(file.path)
    local icon, _ = utils.get_icon(fname)
    local hls = {}

    if unique_res[fname] then
      fname = utils.get_file_name(file.path, true)
    end

    local opt_max_width = self.opts.board.max_filename
    if #fname > opt_max_width then
      fname = string.sub(fname, 1, opt_max_width)
      fname = fname .. '...'
    end
    if #fname > max_fname_len then
      max_fname_len = #fname
    end

    local prefix = tostring(index)
    if index == 10 then
      prefix = '0'
    end
    if file.pinned then
      prefix = self.opts.board.pin_icon
    end

    local unsaved = ' '
    if unsaved_files[file.path] then
      unsaved = '*'
    end

    local rank_txt = string.format('%s[%s] %s %s ', unsaved, prefix, icon, fname)

    if utils.get_current_filepath() == file.path then
      local hl_cur = {
        hl_group = 'CursorLineNr',
        col_start = 0,
        col_end = -1,
      }
      table.insert(hls, hl_cur)
    end

    table.insert(board_list, {
      index = index,
      rank_txt = rank_txt,
      hls = hls,
    })
  end

  self.board:set_width(max_fname_len)
  self.board:set_height(#rank_list)

  return board_list
end

function App:render()
  local board_list = self:get_board_list()
  self.board:render(board_list)
end

function App:show()
  self:render()
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

function App:close()
  self:hide()
end

function App:go_to(index)
  if index == 0 then
    index = 10
  end

  if not index then
    return
  end

  local file = self.rank:get_file(index)

  if not file then
    return
  end

  if vim.fn.filereadable(file.path) == 0 then
    self.rank:remove_by_index(index)
    utils.notify(string.format('%s does not exist, rank record deleted.', file.path))
    self:render()
    return
  end

  vim.cmd(':edit ' .. file.path)
end

function App:toggle_pin()
  self.rank:toggle_pin()
  if self.board:ishow() then
    self:render()
  end
end

function App:remove()
  self.rank:remove()
  if self.board:ishow() then
    self:render()
  end
end

function App:remove_all()
  self.rank:remove_all()
  if self.board:ishow() then
    self:render()
  end
end

function App:prev_pinned()
  local index = self.rank:prev_pinned_index()
  if not index then
    return
  end

  self:go_to(index)
end

function App:next_pinned()
  local index = self.rank:next_pinned_index()
  if not index then
    return
  end

  self:go_to(index)
end

function App:run()
  self:data_init()
  self:start_monitor_bufs()
  self:render()
end

return App
