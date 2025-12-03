-- C++ Quick Run Keybindings
return {
  {
    "neovim/nvim-lspconfig",
    opts = {},
    init = function()
      -- C++ Run keybindings (only for C/C++ files)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "cpp", "c" },
        callback = function()
          local opts = { buffer = true, silent = false }

          -- Compile current file
          vim.keymap.set("n", "<leader>cc", function()
            local file = vim.fn.expand("%")
            local output = vim.fn.expand("%:r")
            vim.cmd(string.format("!g++ -std=c++17 %s -o %s", file, output))
          end, vim.tbl_extend("force", opts, { desc = "C++: Compile" }))

          -- Compile with debug symbols
          vim.keymap.set("n", "<leader>cC", function()
            local file = vim.fn.expand("%")
            local output = vim.fn.expand("%:r")
            vim.cmd(string.format("!g++ -g -std=c++17 %s -o %s", file, output))
          end, vim.tbl_extend("force", opts, { desc = "C++: Compile (Debug)" }))

          -- Run current file's executable
          vim.keymap.set("n", "<leader>cx", function()
            local output = vim.fn.expand("%:r")
            if vim.fn.filereadable(output) == 1 then
              vim.cmd("!" .. output)
            else
              vim.notify("Executable not found. Compile first with <leader>cc", vim.log.levels.WARN)
            end
          end, vim.tbl_extend("force", opts, { desc = "C++: Run" }))

          -- Compile and run in one command
          vim.keymap.set("n", "<leader>cR", function()
            local file = vim.fn.expand("%")
            local output = vim.fn.expand("%:r")
            vim.cmd(string.format("!g++ -std=c++17 %s -o %s && %s", file, output, output))
          end, vim.tbl_extend("force", opts, { desc = "C++: Compile & Run" }))

          -- Compile and run in terminal split
          vim.keymap.set("n", "<leader>cX", function()
            local file = vim.fn.expand("%")
            local output = vim.fn.expand("%:r")
            vim.cmd(string.format("split | terminal g++ -std=c++17 %s -o %s && %s", file, output, output))
          end, vim.tbl_extend("force", opts, { desc = "C++: Run in Terminal Split" }))
        end,
      })
    end,
  },
}
