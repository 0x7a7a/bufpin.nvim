local webdevicons = require('nvim-web-devicons')

local M = {}

---Get file icon from nvim-web-devicons
---@param fname string
---@return string
---@return string
function M.get_icon(fname)
  local ext = vim.fn.fnamemodify(fname, ':e')
  local icon, hl_group = webdevicons.get_icon(fname, ext, { default = true })

  return icon, hl_group
end

---Get the tail filename or with parent dir
---@param fpath string
---@param parent boolean? only file name
---@return string
function M.get_file_name(fpath, parent)
  if #fpath == 0 then
    return ''
  end

  local delimiter = package.config:sub(1, 1)
  local pattern = '[^' .. delimiter .. ']+'

  local dirs = {}
  for p in string.gmatch(fpath, pattern) do
    table.insert(dirs, p)
  end

  parent = parent or false
  if parent and #dirs > 2 then
    return dirs[#dirs - 1] .. '/' .. dirs[#dirs]
  end
  return dirs[#dirs]
end

---Absolute path to the current buf file
function M.get_current_filepath()
  return vim.fn.expand('%:p')
end

---Recursively check for git files to determine if the working directory is a git repository.
---NOTE: Problems may arise where there are submodules
---@return boolean
function M.is_git_repo()
  local git_files = vim.fs.find('.git', { upward = true, stop = vim.loop.os_homedir() })
  return #git_files ~= 0
end

---@param msg string
function M.notify(msg)
  vim.notify(string.format('[bufpin.nvim]: %s', msg))
end

---@param file_path string
---@return string
function M.encode(file_path)
  local path, _ = string.gsub(file_path, '/', '%%')
  return path
end

---Just for simple debug
---@param ... any
function M.log(...)
  local p = vim.fn.stdpath('cache') .. '/bufpin/log'
  vim.fn.writefile({ ... }, p)
end

return M
