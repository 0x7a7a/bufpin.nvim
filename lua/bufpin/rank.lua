local utils = require('bufpin.utils')

local Rank = {}

function Rank:new(opts, storage)
  return setmetatable({
    topn = opts.topn,
    storage = storage,
    list = {},
  }, { __index = self })
end

function Rank:init()
  self.list = self.storage:get_all()
  self:check()
end

function Rank:get_file(index)
  return self.list[index]
end

-- check list length
-- delete duplicate and empty file name
function Rank:check()
  local set = {}
  local res = {}
  for _, v in pairs(self.list) do
    if v.path ~= nil and v.pinned ~= nil then
      if not set[v.path] then
        table.insert(res, v)
        set[v.path] = true
      end
    end
  end
  self.list = res

  while #self.list > self.topn do
    table.remove(self.list)
  end
end

function Rank:rise(file_path)
  if #file_path == 0 then
    return
  end

  local old_index
  local new_index
  for k, v in pairs(self.list) do
    if v.path == file_path then
      old_index = k
      if v.pinned then
        return
      end
    end

    if not v.pinned and not new_index then
      new_index = k
    end
  end

  -- same position
  if old_index == new_index and old_index ~= nil then
    return
  end

  -- empty list
  if #self.list == 0 then
    new_index = 1
  end

  -- full list
  if not old_index and #self.list == self.topn then
    return
  end

  local new_rank_item = { path = file_path, pinned = false }

  -- swap position and reorder
  if old_index and new_index then
    local old_rank_item = table.remove(self.list, new_index)
    table.insert(self.list, new_index, new_rank_item)

    if old_index then
      table.remove(self.list, old_index)
    end

    -- find the nearest unpinned
    for i = new_index + 1, #self.list, 1 do
      local v = self.list[i]
      if not v.pinned then
        table.insert(self.list, i, old_rank_item)
      end
    end
    new_rank_item = old_rank_item
  end

  -- all pinned
  table.insert(self.list, new_rank_item)

  self:save()
end

function Rank:get_pin_index(path)
  for index, file in pairs(self.list) do
    if file.path == path then
      return index
    end
  end
  return nil
end

function Rank:get_cur_file_index()
  local index = self:get_pin_index(utils.get_current_filepath())
  if not index then
    return nil
  end
  return index
end

function Rank:toggle_pin()
  local index = self:get_pin_index(utils.get_current_filepath())
  if not index then
    return
  end

  local file = self.list[index]
  if not file then
    return
  end

  if file.pinned then
    self.list[index].pinned = false
  else
    self.list[index].pinned = true
  end

  self:save()
end

function Rank:remove()
  local index = self:get_cur_file_index()
  if not index then
    return
  end

  table.remove(self.list, index)
  self:save()
end

function Rank:remove_by_index(index)
  table.remove(self.list, index)
  self:save()
end

function Rank:remove_all()
  self.list = {}
  self:save()
end

function Rank:save()
  self.storage:save(self.list)
end

function Rank:async_save()
  self:save()
end

function Rank:prev_pinned_index()
  local index = self:get_cur_file_index() or 1
  for i = index - 1, 1, -1 do
    if self.list[i].pinned then
      return i
    end
  end

  for i = #self.list, index, -1 do
    if self.list[i].pinned then
      return i
    end
  end

  return nil
end

function Rank:next_pinned_index()
  local index = self:get_cur_file_index() or 1
  for i = index + 1, #self.list, 1 do
    if self.list[i].pinned then
      return i
    end
  end

  for i = index - 1, 1, -1 do
    if self.list[i].pinned then
      return i
    end
  end

  return nil
end

function Rank:count()
  return #self.list
end

function Rank:raw()
  return self.list
end

return Rank
