return {
  -- C++ LSP configuration with clangd
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {
          -- Clangd command-line options
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
          },
          -- Use offsetEncoding for compatibility
          capabilities = {
            offsetEncoding = { "utf-16" },
          },
          -- Additional settings
          init_options = {
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
          },
        },
      },
    },
  },

  -- C++ debugging with codelldb
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      -- Ensure codelldb is installed
      {
        "mason-org/mason.nvim",
        opts = function(_, opts)
          opts.ensure_installed = opts.ensure_installed or {}
          vim.list_extend(opts.ensure_installed, { "codelldb" })
        end,
      },
    },
    opts = function()
      local dap = require("dap")

      -- Configure codelldb adapter
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
          args = { "--port", "${port}" },
        },
      }

      -- C++ debug configurations
      dap.configurations.cpp = {
        {
          name = "Launch file",
          type = "codelldb",
          request = "launch",
          program = function()
            -- Try to find common executable names in current directory
            local cwd = vim.fn.getcwd()
            local potential_exes = {
              "a.out",
              "main",
              "test",
              vim.fn.fnamemodify(vim.fn.expand("%:r"), ":t"), -- Current file without extension
            }

            -- Check if any exist
            for _, exe in ipairs(potential_exes) do
              local path = cwd .. "/" .. exe
              if vim.fn.filereadable(path) == 1 then
                -- Found a likely executable, but still prompt for confirmation
                return vim.fn.input("Path to executable: ", path, "file")
              end
            end

            -- Default: prompt with current directory
            return vim.fn.input("Path to executable: ", cwd .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
        {
          name = "Attach to process",
          type = "codelldb",
          request = "attach",
          pid = function()
            local handle = io.popen("ps aux | grep -v grep | awk '{print $2, $11}'")
            if handle then
              local result = handle:read("*a")
              handle:close()
              return require("dap.utils").pick_process({ filter = result })
            end
          end,
          cwd = "${workspaceFolder}",
        },
      }

      -- C configurations (same as C++)
      dap.configurations.c = dap.configurations.cpp

      -- Rust configurations (codelldb also works for Rust)
      dap.configurations.rust = dap.configurations.cpp
    end,
  },


  -- C++ formatter (optional - clangd can format too)
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        cpp = { "clang_format" },
        c = { "clang_format" },
      },
      formatters = {
        clang_format = {
          prepend_args = {
            "--style={BasedOnStyle: Google, IndentWidth: 4, ColumnLimit: 100}",
          },
        },
      },
    },
  },
}
