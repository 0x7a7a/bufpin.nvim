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

  -- search last pinned file
  local index
  for k, v in pairs(self.list) do
    if v.path == file_path and v.pinned then
      return
    end

    if not v.pinned then
      index = k
      break
    end
  end

  if #self.list == 0 then
    index = 1
  end

  if index then
    table.insert(self.list, index, { path = file_path, pinned = false })
  end

  self:check()
  self:save()
end

function Rank:down()
  self:check()
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

function Rank:get_file_index()
  local index = self:get_pin_index(utils.get_current_filepath())
  if not index then
    return nil
  end
  return index
end

function Rank:toggle_pin()
  local index = self:get_file_index()
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
end

function Rank:remove()
  local index = self:get_file_index()
  if not index then
    return
  end

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
  -- TODO: save in ExitPre event
end

function Rank:count()
  return #self.list
end

function Rank:raw()
  return self.list
end

return Rank
