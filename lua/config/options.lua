-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Configure Python provider for Molten and other Python plugins
-- Use the conda environment's Python if available, otherwise use system Python
local function get_python_path()
  local conda_prefix = vim.env.CONDA_PREFIX
  if conda_prefix then
    return conda_prefix .. "/bin/python"
  else
    return vim.fn.exepath("python3") or "/opt/homebrew/bin/python3"
  end
end

vim.g.python3_host_prog = get_python_path()

-- Add PostgreSQL 18 to PATH for vim-dadbod
vim.env.PATH = "/opt/homebrew/opt/postgresql@18/bin:" .. vim.env.PATH
