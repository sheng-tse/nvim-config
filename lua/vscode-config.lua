-- VS Code/Antigravity specific keybindings
local vscode = require("vscode-neovim")

-- Add lazy.nvim plugin paths
local lazy_path = vim.fn.stdpath("data") .. "/lazy"
package.path = package.path .. ";" .. lazy_path .. "/?.lua;" .. lazy_path .. "/?/init.lua"

-- Add all lazy plugins to runtimepath
local scan = vim.fn.glob(lazy_path .. "/*", true, true)
for _, plugin_path in ipairs(scan) do
  vim.opt.runtimepath:append(plugin_path)
end

-- Load VSCode-compatible plugins (works in both VSCode and Antigravity)
local vscode_plugins = {
  { "mini.ai", function() require("mini.ai").setup() end },
  { "mini.pairs", function() require("mini.pairs").setup() end },
  { "mini.surround", function() require("mini.surround").setup() end },
  { "mini.operators", function()
    require("mini.operators").setup({
      exchange = { prefix = "gx" },
      replace = { prefix = "gR" },
    })
  end },
}

for _, plugin in ipairs(vscode_plugins) do
  local name, setup = plugin[1], plugin[2]
  pcall(setup)
end

-- ============================================================================
-- Keybindings that work in BOTH VSCode and Antigravity (no leader key)
-- ============================================================================

-- LSP navigation
vim.keymap.set("n", "gr", function() vscode.action("editor.action.goToReferences") end)
vim.keymap.set("n", "gd", function() vscode.action("editor.action.revealDefinition") end)
vim.keymap.set("n", "gD", function() vscode.action("editor.action.revealDeclaration") end)
vim.keymap.set("n", "gi", function() vscode.action("editor.action.goToImplementation") end)
vim.keymap.set("n", "gt", function() vscode.action("editor.action.goToTypeDefinition") end)
vim.keymap.set("n", "K", function() vscode.action("editor.action.showHover") end)

-- Diagnostics
vim.keymap.set("n", "[d", function() vscode.action("editor.action.marker.prev") end)
vim.keymap.set("n", "]d", function() vscode.action("editor.action.marker.next") end)

-- Window/Tab management
vim.keymap.set("n", "<C-h>", function() vscode.action("workbench.action.focusLeftGroup") end)
vim.keymap.set("n", "<C-l>", function() vscode.action("workbench.action.focusRightGroup") end)
vim.keymap.set("n", "<C-j>", function() vscode.action("workbench.action.focusBelowGroup") end)
vim.keymap.set("n", "<C-k>", function() vscode.action("workbench.action.focusAboveGroup") end)

-- Comments
vim.keymap.set("n", "gcc", function() vscode.action("editor.action.commentLine") end)
vim.keymap.set("v", "gc", function() vscode.action("editor.action.commentLine") end)

-- Debugging
vim.keymap.set("n", "<F5>", function() vscode.action("workbench.action.debug.start") end)
vim.keymap.set("n", "<F9>", function() vscode.action("editor.debug.action.toggleBreakpoint") end)
vim.keymap.set("n", "<F10>", function() vscode.action("workbench.action.debug.stepOver") end)
vim.keymap.set("n", "<F11>", function() vscode.action("workbench.action.debug.stepInto") end)

-- File operations using command-line abbreviations
vim.cmd([[
  cnoreabbrev w <C-u>call VSCodeNotify('workbench.action.files.save')<CR>
  cnoreabbrev W <C-u>call VSCodeNotify('workbench.action.files.save')<CR>
  cnoreabbrev q <C-u>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>
  cnoreabbrev Q <C-u>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>
  cnoreabbrev wq <C-u>call VSCodeNotify('workbench.action.files.save')<CR><C-u>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>
  cnoreabbrev Wq <C-u>call VSCodeNotify('workbench.action.files.save')<CR><C-u>call VSCodeNotify('workbench.action.closeActiveEditor')<CR>
  cnoreabbrev wa <C-u>call VSCodeNotify('workbench.action.files.saveAll')<CR>
  cnoreabbrev Wa <C-u>call VSCodeNotify('workbench.action.files.saveAll')<CR>
  cnoreabbrev wqa <C-u>call VSCodeNotify('workbench.action.files.saveAll')<CR><C-u>call VSCodeNotify('workbench.action.closeAllEditors')<CR>
  cnoreabbrev Wqa <C-u>call VSCodeNotify('workbench.action.files.saveAll')<CR><C-u>call VSCodeNotify('workbench.action.closeAllEditors')<CR>
]])

-- ============================================================================
-- Leader key mappings (VSCode ONLY - Antigravity doesn't support leader keys)
-- ============================================================================
if vim.g.vscode then
  vim.g.mapleader = " "
  vim.g.maplocalleader = " "

  -- Code actions
  vim.keymap.set("n", "<leader>ca", function() vscode.action("editor.action.quickFix") end)
  vim.keymap.set("n", "<leader>rn", function() vscode.action("editor.action.rename") end)
  vim.keymap.set("n", "<leader>f", function() vscode.action("editor.action.formatDocument") end)
  vim.keymap.set("v", "<leader>f", function() vscode.action("editor.action.formatSelection") end)
  vim.keymap.set("n", "<leader>d", function() vscode.action("editor.action.showHover") end)

  -- File navigation
  vim.keymap.set("n", "<leader>ff", function() vscode.action("workbench.action.quickOpen") end)
  vim.keymap.set("n", "<leader>fg", function() vscode.action("workbench.action.findInFiles") end)
  vim.keymap.set("n", "<leader>fb", function() vscode.action("workbench.action.showAllEditors") end)
  vim.keymap.set("n", "<leader>e", function() vscode.action("workbench.view.explorer") end)

  -- Split management
  vim.keymap.set("n", "<leader>sv", function() vscode.action("workbench.action.splitEditorRight") end)
  vim.keymap.set("n", "<leader>sh", function() vscode.action("workbench.action.splitEditorDown") end)

  -- Git
  vim.keymap.set("n", "<leader>gb", function() vscode.action("git.viewHistory") end)
  vim.keymap.set("n", "<leader>gs", function() vscode.action("workbench.view.scm") end)
end
