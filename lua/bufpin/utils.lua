local webdevicons = require('nvim-web-devicons')

local M = {}

---@param arr table
function M.unique(arr)
  local set = {}
  local res = {}

  for _, v in pairs(arr) do
    if not set[v] then
      table.insert(res, v)
      set[v] = true
    end
  end

  return res
end

---@param fname string
function M.get_icon(fname)
  local ext = vim.fn.fnamemodify(fname, ':e')
  local icon, hl_group = webdevicons.get_icon(fname, ext, { default = true })

  return icon, hl_group
end

function M.get_file_name(fname)
  return vim.fn.fnamemodify(fname, ':t')
end

return M
