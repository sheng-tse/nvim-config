return {
  -- Core DAP plugin (already installed as dependency for Java, but we'll configure it here)
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- UI for better debugging experience
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio", -- Required by nvim-dap-ui

      -- Virtual text showing variable values inline
      "theHamsta/nvim-dap-virtual-text",

      -- Python debugging
      {
        "mfussenegger/nvim-dap-python",
        ft = "python",
      },
    },
    keys = {
      -- Basic debugging controls
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Toggle Breakpoint",
      },
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end,
        desc = "Conditional Breakpoint",
      },
      {
        "<leader>dc",
        function()
          require("dap").continue()
        end,
        desc = "Continue/Start Debug",
      },
      {
        "<leader>dS",
        function()
          -- Force show config picker by passing empty opts
          local dap = require("dap")
          if vim.bo.filetype == "python" then
            -- For Python, manually trigger picker
            vim.ui.select(dap.configurations.python, {
              prompt = "Select configuration:",
              format_item = function(config)
                return config.name
              end,
            }, function(config)
              if config then
                dap.run(config)
              end
            end)
          else
            dap.continue()
          end
        end,
        desc = "Start Debug (Select Config)",
      },
      {
        "<leader>di",
        function()
          require("dap").step_into()
        end,
        desc = "Step Into",
      },
      {
        "<leader>do",
        function()
          require("dap").step_over()
        end,
        desc = "Step Over",
      },
      {
        "<leader>dO",
        function()
          require("dap").step_out()
        end,
        desc = "Step Out",
      },
      {
        "<leader>dt",
        function()
          require("dap").terminate()
        end,
        desc = "Terminate Debug",
      },
      {
        "<leader>dr",
        function()
          require("dap").restart()
        end,
        desc = "Restart Debug",
      },

      -- Python-specific debugging
      {
        "<leader>dm",
        function()
          require("dap-python").test_method()
        end,
        desc = "Debug Test Method",
        ft = "python",
      },
      {
        "<leader>dM",
        function()
          require("dap-python").test_class()
        end,
        desc = "Debug Test Class",
        ft = "python",
      },
      {
        "<leader>ds",
        function()
          require("dap-python").debug_selection()
        end,
        desc = "Debug Selection",
        mode = "v",
        ft = "python",
      },

      -- DAP UI controls
      {
        "<leader>du",
        function()
          require("dapui").toggle()
        end,
        desc = "Toggle DAP UI",
      },
      {
        "<leader>de",
        function()
          require("dapui").eval()
        end,
        desc = "Eval Expression",
        mode = { "n", "v" },
      },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- Setup DAP UI with default configuration
      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
        mappings = {
          expand = { "<CR>", "<2-LeftMouse>" },
          open = "o",
          remove = "d",
          edit = "e",
          repl = "r",
          toggle = "t",
        },
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.25 },
              { id = "breakpoints", size = 0.25 },
              { id = "stacks", size = 0.25 },
              { id = "watches", size = 0.25 },
            },
            size = 40,
            position = "left",
          },
          {
            elements = {
              { id = "repl", size = 0.5 },
              { id = "console", size = 0.5 },
            },
            size = 10,
            position = "bottom",
          },
        },
        floating = {
          max_height = nil,
          max_width = nil,
          border = "single",
          mappings = {
            close = { "q", "<Esc>" },
          },
        },
        controls = {
          enabled = true,
        },
      })

      -- Clean up DAP terminal buffers on session end
      -- This prevents buffer conflicts between debug sessions
      dap.listeners.after.event_terminated["cleanup_buffers"] = function()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.bo[buf].buftype == "terminal" then
            local bufname = vim.api.nvim_buf_get_name(buf)
            if bufname:match("debugpy") or bufname:match("dap") then
              pcall(vim.api.nvim_buf_delete, buf, { force = true })
            end
          end
        end
      end

      -- Setup virtual text to show variable values inline
      require("nvim-dap-virtual-text").setup({
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        highlight_new_as_changed = false,
        show_stop_reason = true,
        commented = false,
        only_first_definition = true,
        all_references = false,
        filter_references_pattern = "<module",
        virt_text_pos = "eol",
        all_frames = false,
        virt_lines = false,
        virt_text_win_col = nil,
      })

      -- Setup Python debugging
      -- Use debugpy-adapter executable instead of python path
      local dap_python = require("dap-python")
      local debugpy_adapter = vim.fn.stdpath("data") .. "/mason/packages/debugpy/debugpy-adapter"
      if vim.fn.filereadable(debugpy_adapter) == 1 then
        -- Use the debugpy-adapter executable
        dap_python.setup(debugpy_adapter)
      else
        -- Fallback: try Mason's python venv
        local debugpy_path = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
        if vim.fn.filereadable(debugpy_path) == 1 then
          dap_python.setup(debugpy_path)
        else
          -- Last resort: system python3
          dap_python.setup("python3")
        end
      end

      -- Configure Python debugger to use internalConsole
      -- This prevents the "unmodified buffer" terminal error
      -- Must be done AFTER dap-python.setup() creates the configurations
      vim.schedule(function()
        for _, config in ipairs(dap.configurations.python or {}) do
          config.console = "internalConsole"
        end
      end)

      -- Override dap.continue to auto-select first config for Python and C/C++
      local original_continue = dap.continue
      dap.continue = function(opts)
        local ft = vim.bo.filetype

        -- Only override for Python and C/C++ files
        if ft ~= "python" and ft ~= "cpp" and ft ~= "c" then
          return original_continue(opts)
        end

        -- If already in session or opts provided, use normal continue
        if dap.session() or opts then
          return original_continue(opts)
        end

        -- Auto-select first config (usually "Launch file" or "file")
        local configs = dap.configurations[ft]
        if configs and #configs > 0 then
          return dap.run(configs[1])
        end

        -- Fallback to normal continue
        return original_continue(opts)
      end

      -- Auto-open/close DAP UI when debugging starts/stops
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- DAP signs for breakpoints and current line
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = "→", texthl = "DapStopped", linehl = "DapStoppedLine", numhl = "" })
      vim.fn.sign_define("DapLogPoint", { text = "◎", texthl = "DapLogPoint", linehl = "", numhl = "" })

      -- Highlight groups for DAP
      vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#e51400" })
      vim.api.nvim_set_hl(0, "DapLogPoint", { fg = "#61afef" })
      vim.api.nvim_set_hl(0, "DapStopped", { fg = "#98c379" })
      vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#31353f" })
    end,
  },
}
