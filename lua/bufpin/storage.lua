local Pins = {
  pins = {
    -- '/Users/lucky/dev/project/neovim-plugins/pin.nvim/lua/pin.lua',
    -- '/Users/lucky/dev/project/neovim-plugins/pin.nvim/lua/app.lua',
    -- '/Users/lucky/dev/project/neovim-plugins/pin.nvim/lua/config.lua',
    'pin.go',
    'app.js',
    'config.lua',
    'config.rs',
    'config.ts',
    'application/config.vue',
    'something/config.vue',
  },
}

function Pins:new()
  return self
end

function Pins:count()
  return #self.pins
end

function Pins:get_all()
  return self.pins
end

return Pins
