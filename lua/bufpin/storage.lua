local utils = require('bufpin.utils')
local Storage = {}

function Storage:new(opts)
  return setmetatable({
    dir = opts.dir,
    git_branch = opts.git_branch,
  }, { __index = self })
end

function Storage:get_file_path()
  local cwd = vim.fn.getcwd()

  if vim.fn.isdirectory(self.dir) == 0 then
    vim.fn.mkdir(self.dir, 'p')
  end

  local fpath = self.dir .. vim.base64.encode(cwd)

  if self.git_branch and utils.is_git_repo() then
    local result = vim.fn.system({ 'git', 'symbolic-ref', '--short', 'HEAD' })
    local branch = vim.trim(string.gsub(result, '\n', ''))

    fpath = string.format('%s-%s', fpath, branch)
  end

  return fpath
end

function Storage:get_all()
  local fpath = self:get_file_path()
  if vim.fn.filereadable(fpath) == 0 then
    return {}
  end

  local ok, content = pcall(vim.fn.readfile, fpath)
  if not ok or #content == 0 then
    return {}
  end

  local ok, list = pcall(vim.fn.json_decode, content)
  if not ok then
    vim.notify('BufPin: json decode error')
    return {}
  end
  return list
end

function Storage:save(list)
  local encode = vim.fn.json_encode(list)
  local ok = pcall(vim.fn.writefile, { encode }, self:get_file_path())
  if not ok then
    vim.notify('BufPin: failed to write file')
  end
end

return Storage
