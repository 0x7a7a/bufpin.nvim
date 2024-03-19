local Storage = {
  pins = {
    -- '/Users/lucky/dev/project/neovim-plugins/pin.nvim/lua/pin.lua',
    -- '/Users/lucky/dev/project/neovim-plugins/pin.nvim/lua/app.lua',
    -- '/Users/lucky/dev/project/neovim-plugins/pin.nvim/lua/config.lua',
    { path = './pin.go', pinned = false },
    { path = '/Home/dir/pin.rs', pinned = false },
    { path = 'something/pin.js', pinned = false },
    { path = 'otherthing/pin.lua', pinned = false },
  },
}

function Storage:new()
  return self
end

function Storage:get_all()
  return {}
end

function Storage:save() end

return Storage
