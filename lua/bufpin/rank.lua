local Storage = require('bufpin.storage')
local utils = require('bufpin.utils')

local Rank = {
  list = {},
}

function Rank:new(topn)
  self.topn = topn
  self.storage = Storage:new()

  self:async_save()

  return self
end

function Rank:init()
  self.list = self.storage:get_all()
  self:check()
end

-- check list length
-- delete duplicate file name
function Rank:check()
  -- unique and clean
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
end

function Rank:down()
  self:check()
end

function Rank:pin(index)
  local file = self.list[index]
  if not file or file.pinned then
    return
  end

  self.list[index].pinned = true
end

function Rank:unpin(index)
  local file = self.list[index]
  if not file or not file.pinned then
    return
  end

  self.list[index].pinned = false
end

function Rank:remove(index)
  table.remove(self.list, index)
end

function Rank:raw()
  return self.list
end

function Rank:async_save()
  self.storage:save()
end

return Rank
