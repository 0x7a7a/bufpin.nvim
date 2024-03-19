local Config = {}
local default_opts = {
  icon = ' ',
}

--- @class Config
--- @field window table
function Config:new(opts)
  self:merge(opts)
  return self
end

function Config:merge(opts)
  self.opts = vim.tbl_deep_extend('keep', opts, default_opts)
end

function Config:get(name)
  return self.opts[name]
end

return Config
