## BufPin.nvim📌
BufPin.nvim is a plugin for displaying recent files and quickly switching between them. It features a togglable board that can move along with the window, helping you swiftly navigate through multiple files.

## Features
- The buffer list is automatically sorted based on the order of recently opened/switched files.
- Use the "pinning" feature to keep files unaffected by the sorting rules, and quickly switch between them using custom keybindings.
- The dynamic mini-menu automatically follows as you switch between windows.
- Duplicate files are automatically displayed with their parent directory.
- The file list is separated by Git branch.

## Differences from Harpoon or Others
- Adds a list of recent files.
- Persistent mini-menu aids in remembering file names.

## Installation and keybindings
### Lazy
```lua
return {
  '0x7a7a/bufpin.nvim',
  event = 'VeryLazy',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    local bufpin = require('bufpin')
    bufpin.setup()

    -- You can customize the keys to whatever you like!
    -- stylua: ignore start
    Keymap('n', '<A-1>', function() bufpin.go_to(1) end, { desc = 'BufPin: go to file 1' })
    Keymap('n', '<A-2>', function() bufpin.go_to(2) end, { desc = 'BufPin: go to file 2' })
    Keymap('n', '<A-3>', function() bufpin.go_to(3) end, { desc = 'BufPin: go to file 3' })
    Keymap('n', '<A-4>', function() bufpin.go_to(4) end, { desc = 'BufPin: go to file 4' })
    Keymap('n', '<A-5>', function() bufpin.go_to(5) end, { desc = 'BufPin: go to file 5' })
    Keymap('n', '<C-e>', function() bufpin.toggle() end, { desc = 'BufPin: toggle board' })
    Keymap('n', '<leader>pp', function() bufpin.toggle_pin() end, { desc = 'BufPin: toggle pin' })
    Keymap('n', '<leader>pr', function() bufpin.remove() end, { desc = 'BufPin: remove entry' })
    Keymap('n', '<leader>pa', function() bufpin.remove_all() end, { desc = 'BufPin: remove all entry' })
    Keymap('n', '<A-h>', function() bufpin.prev_pinned() end, { desc = 'BufPin: toggle pin' })
    Keymap('n', '<A-l>', function() bufpin.next_pinned() end, { desc = 'BufPin: toggle pin' })
  end
}
```
All APIs can be found in[lua/bufpin/init.lua](https://github.com/0x7a7a/bufpin.nvim/blob/master/lua/bufpin/init.lua)


## Default Setting
```lua
{
  rank = {
    num = 10, -- number of the files displayed on the board
  },
  storage = {
    dir = vim.fn.stdpath('cache') .. '/bufpin/',
    git_branch = true,
  },
  board = {
    mode = 'follow', -- follow or fixed on the right edge of the window
    pin_icon = '󰐃',
    border = 'none', -- single / double / rounder /none
    max_filename = 20, -- long filenames are replaced with ellipses

    -- border_height is automatically calculated based on the displayed content.
    float_height = function(border_height)
      -- the default is vertical-center
      local win_height = vim.fn.winheight(0)
      return math.floor((win_height - border_height) / 2)
    end,
  },
  ignore_ft = {
    'help',
    'http',
    'mason',
    'neotest-summary',
  },
}
```

## Other similar plugins
- [harpoon](https://github.com/ThePrimeagen/harpoon)
- [grapple.nvim](https://github.com/cbochs/grapple.nvim)
- [arrow.nvim](https://github.com/otavioschwanck/arrow.nvim)
