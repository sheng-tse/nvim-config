-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Helper: Detect OS
local function get_os()
  local uname = vim.loop.os_uname()
  if uname.sysname == "Darwin" then
    return "macos"
  elseif uname.sysname == "Linux" then
    return "linux"
  elseif uname.sysname:match("Windows") then
    return "windows"
  end
  return "unknown"
end

-- Configure Python provider for Molten and other Python plugins
-- Use the conda environment's Python if available, otherwise use system Python
local function get_python_path()
  -- Priority: CONDA_PREFIX > VIRTUAL_ENV > system python3
  local conda_prefix = vim.env.CONDA_PREFIX
  if conda_prefix then
    local sep = get_os() == "windows" and "\\Scripts\\python.exe" or "/bin/python"
    return conda_prefix .. sep
  end

  local virtual_env = vim.env.VIRTUAL_ENV
  if virtual_env then
    local sep = get_os() == "windows" and "\\Scripts\\python.exe" or "/bin/python"
    return virtual_env .. sep
  end

  -- Use system python3 (works on all platforms)
  local python = vim.fn.exepath("python3")
  if python and python ~= "" then
    return python
  end

  -- Fallback for Windows where python3 might not exist
  return vim.fn.exepath("python") or "python3"
end

vim.g.python3_host_prog = get_python_path()

-- Add PostgreSQL to PATH for vim-dadbod (if installed)
-- This searches common installation paths across platforms
local function setup_postgresql_path()
  local os_type = get_os()
  local pg_paths = {}

  if os_type == "macos" then
    -- Homebrew paths (both ARM and Intel), newest versions first
    pg_paths = {
      "/opt/homebrew/opt/postgresql@18/bin",
      "/opt/homebrew/opt/postgresql@17/bin",
      "/opt/homebrew/opt/postgresql@16/bin",
      "/opt/homebrew/opt/postgresql@15/bin",
      "/opt/homebrew/opt/postgresql/bin",
      "/usr/local/opt/postgresql@18/bin",
      "/usr/local/opt/postgresql@17/bin",
      "/usr/local/opt/postgresql@16/bin",
      "/usr/local/opt/postgresql@15/bin",
      "/usr/local/opt/postgresql/bin",
    }
  elseif os_type == "linux" then
    pg_paths = {
      "/usr/lib/postgresql/17/bin",
      "/usr/lib/postgresql/16/bin",
      "/usr/lib/postgresql/15/bin",
      "/usr/bin",
    }
  end

  for _, pg_path in ipairs(pg_paths) do
    if vim.fn.isdirectory(pg_path) == 1 then
      vim.env.PATH = pg_path .. ":" .. vim.env.PATH
      break
    end
  end
end

setup_postgresql_path()
