-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- NOTE: Java build/run keybindings (<leader>jb, jr, jt, jc, jp, jk) are now handled by overseer.nvim
-- See lua/plugins/overseer.lua for configuration

-- Helper function to create new Java class with proper package
local function create_java_class()
  local cwd = vim.fn.getcwd()
  local src_main = cwd .. "/app/src/main/java/"
  local src_test = cwd .. "/app/src/test/java/"

  -- Ask user for class name and type
  local class_name = vim.fn.input("Class name: ")
  if class_name == "" then return end

  local choices = { "1. Main source (app/src/main/java/)", "2. Test source (app/src/test/java/)" }
  local choice = vim.fn.inputlist(choices)

  local base_path = choice == 2 and src_test or src_main

  -- Ask for package (optional)
  local package = vim.fn.input("Package (e.g., com.example.util or leave empty): ")

  local file_path
  if package ~= "" then
    -- Convert package to path (com.example.util -> com/example/util)
    local package_path = package:gsub("%.", "/")
    local full_path = base_path .. package_path
    vim.fn.mkdir(full_path, "p")
    file_path = full_path .. "/" .. class_name .. ".java"
  else
    file_path = base_path .. class_name .. ".java"
  end

  -- Create and open the file
  vim.cmd("edit " .. file_path)

  -- Insert package declaration and class template
  local lines = {}
  if package ~= "" then
    table.insert(lines, "package " .. package .. ";")
    table.insert(lines, "")
  end
  table.insert(lines, "public class " .. class_name .. " {")
  table.insert(lines, "    ")
  table.insert(lines, "}")

  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.cmd("normal! 3Gzz") -- Jump to line 3 (inside class)
end

-- Keymap to create new Java class
vim.keymap.set("n", "<leader>jn", create_java_class, { desc = "Java: New Class" })
