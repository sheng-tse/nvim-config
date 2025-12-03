-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Load VS Code/Antigravity specific config
-- This will load in both VSCode and Antigravity (any GUI editor)
if vim.g.vscode or not os.getenv('TERM') then
  -- Delay to ensure lazy has loaded
  vim.schedule(function()
    require("vscode-config")
  end)
end
