local Storage = {}

function Storage:new(opts)
  local dir = opts.dir

  return setmetatable({
    dir = dir,
  }, { __index = self })
end

function Storage:get_all()
  return {}
end

function Storage:save(list) end

return Storage
