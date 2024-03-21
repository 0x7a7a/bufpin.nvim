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

-- Check list length
-- Delete duplicate and empty file name
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

function Rank:rise(rise_file)
  if #rise_file == 0 then
    return
  end

  local wait_insert
  for k, v in pairs(self.list) do
    if v.path == rise_file then
      wait_insert = v
      if k == 1 or v.pinned then
        return
      end
    end
  end

  local new_list = {}
  wait_insert = wait_insert or self.storage:new_item(rise_file)
  for _, v in pairs(self.list) do
    if v.path ~= rise_file then
      if v.pinned then
        table.insert(new_list, v)
      else
        table.insert(new_list, wait_insert)
        wait_insert = v
      end
    end
  end
  table.insert(new_list, wait_insert)

  while #new_list > self.topn do
    table.remove(new_list)
  end

  self.list = new_list
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

  self.list[index].pinned = not self.list[index].pinned

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
