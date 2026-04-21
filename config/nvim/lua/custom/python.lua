local M = {}

local function executable(path) return path and vim.fn.executable(path) == 1 end

function M.project_python()
  local virtual_env = vim.env.VIRTUAL_ENV
  if virtual_env and executable(virtual_env .. '/bin/python') then return virtual_env .. '/bin/python' end

  local conda_prefix = vim.env.CONDA_PREFIX
  if conda_prefix and executable(conda_prefix .. '/bin/python') then return conda_prefix .. '/bin/python' end

  local candidates = {
    vim.fn.getcwd() .. '/.venv/bin/python',
    vim.fn.getcwd() .. '/venv/bin/python',
  }

  for _, candidate in ipairs(candidates) do
    if executable(candidate) then return candidate end
  end

  return vim.fn.exepath 'python3'
end

function M.mason_debugpy_python()
  local ok, registry = pcall(require, 'mason-registry')
  if ok and registry.has_package 'debugpy' then
    local package = registry.get_package 'debugpy'
    if package:is_installed() then
      local path = package:get_install_path() .. '/venv/bin/python'
      if executable(path) then return path end
    end
  end

  return M.project_python()
end

return M
