return {
  -- Molten: Execute Jupyter cells in Neovim
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",
    dependencies = {
      "3rd/image.nvim",
    },
    init = function()
      -- Molten configuration
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = true
      vim.g.molten_wrap_output = true
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = false -- Put Out[] below images

      -- Note: Auto-clear images handled by keybinding instead of autocmd
    end,
    keys = {
      -- Initialize Molten for Python
      { "<leader>mi", ":MoltenInit python3<CR>", desc = "Molten Init Python", silent = true },

      -- Execute current cell
      { "<leader>me", ":MoltenEvaluateOperator<CR>", desc = "Molten Eval Operator", silent = true },
      { "<leader>ml", ":MoltenEvaluateLine<CR>", desc = "Molten Eval Line", silent = true },
      { "<leader>mc", ":MoltenReevaluateCell<CR>", desc = "Molten Eval Cell", silent = true },

      -- Visual mode: run selected code
      { "<leader>me", ":<C-u>MoltenEvaluateVisual<CR>gv", desc = "Molten Eval Visual", mode = "v", silent = true },

      -- Navigate cells (requires vim-textobj-hydrogen or custom textobj)
      { "]c", ":MoltenNext<CR>", desc = "Next Molten Cell", silent = true },
      { "[c", ":MoltenPrev<CR>", desc = "Prev Molten Cell", silent = true },

      -- Show/hide output
      { "<leader>mo", ":MoltenShowOutput<CR>", desc = "Molten Show Output", silent = true },
      { "<leader>mh", ":MoltenHideOutput<CR>", desc = "Molten Hide Output", silent = true },
      { "<leader>mO", ":noautocmd MoltenEnterOutput<CR>", desc = "Molten Enter Output", silent = true },

      -- Delete cell output and clear images
      {
        "<leader>md",
        function()
          vim.cmd("MoltenDelete")
          local ok, img = pcall(require, "image")
          if ok then
            img.clear()
          end
        end,
        desc = "Molten Delete Cell + Clear Images",
        silent = true,
      },

      -- Interrupt/restart kernel
      { "<leader>mx", ":MoltenInterrupt<CR>", desc = "Molten Interrupt", silent = true },
      { "<leader>mr", ":MoltenRestart<CR>", desc = "Molten Restart Kernel", silent = true },
    },
  },

  -- Image.nvim: Display images in terminal
  {
    "3rd/image.nvim",
    build = "luarocks --lua-dir=/opt/homebrew/opt/luajit install magick",
    opts = {
      backend = "kitty", -- Use kitty protocol (Ghostty supports this)
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
        },
        neorg = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
        },
        html = {
          enabled = false,
        },
        css = {
          enabled = false,
        },
      },
      max_width = nil,
      max_height = nil,
      max_width_window_percentage = nil,
      max_height_window_percentage = 50,
      window_overlap_clear_enabled = true, -- Enable clearing images when text overlaps
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
      editor_only_render_when_focused = false,
      tmux_show_only_in_active_window = false,
      hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.svg" },
    },
  },

  -- Jupytext: Sync .ipynb with .py files
  {
    "GCBallesteros/jupytext.nvim",
    config = function()
      require("jupytext").setup({
        style = "percent", -- Use # %% for cells
        output_extension = "auto",
        force_ft = nil,
      })

      -- Helper function to create a new notebook file
      local function new_notebook()
        local filename = vim.fn.input("Notebook name: ", "", "file")
        if filename == "" then
          return
        end

        -- Add .ipynb extension if not present
        if not filename:match("%.ipynb$") then
          filename = filename .. ".ipynb"
        end

        -- Get Python version dynamically
        local python_version = "3.0.0"
        local version_output = vim.fn.system("python3 --version 2>&1")
        local major, minor, patch = version_output:match("Python (%d+)%.(%d+)%.(%d+)")
        if major and minor and patch then
          python_version = major .. "." .. minor .. "." .. patch
        end

        -- Get jupytext version and format version dynamically
        local jupytext_version = "1.0.0"
        local format_version = "1.3"
        local jt_info = vim.fn.system([[python3 -c "import jupytext; from jupytext.formats import NOTEBOOK_EXTENSIONS; print(jupytext.__version__); print(NOTEBOOK_EXTENSIONS.get('.py', {}).get('format_version', '1.3'))" 2>&1]])
        if jt_info and not jt_info:match("ModuleNotFoundError") then
          local lines = vim.split(jt_info, "\n")
          if lines[1] then jupytext_version = lines[1]:gsub("%s+", "") end
          if lines[2] then format_version = lines[2]:gsub("%s+", "") end
        end

        -- Get conda environment name if available
        local conda_env = vim.env.CONDA_DEFAULT_ENV or "python3"
        local display_name = conda_env

        -- Create minimal valid notebook JSON with dynamic metadata
        local notebook_template = vim.fn.json_encode({
          cells = {},
          metadata = {
            jupytext = {
              text_representation = {
                extension = ".py",
                format_name = "percent",
                format_version = format_version,
                jupytext_version = jupytext_version,
              },
            },
            kernelspec = {
              display_name = display_name,
              language = "python",
              name = "python3",
            },
            language_info = {
              name = "python",
              version = python_version,
            },
          },
          nbformat = 4,
          nbformat_minor = 2,
        })

        -- Write to file
        local file = io.open(filename, "w")
        if file then
          file:write(notebook_template)
          file:close()
          vim.cmd("edit " .. vim.fn.fnameescape(filename))
          vim.notify("Created notebook: " .. filename .. " (Python " .. python_version .. ")", vim.log.levels.INFO)
        else
          vim.notify("Failed to create notebook", vim.log.levels.ERROR)
        end
      end

      -- Create command and keymap
      vim.api.nvim_create_user_command("NewNotebook", new_notebook, {})
      vim.keymap.set("n", "<leader>jnb", new_notebook, { desc = "Create New Notebook" })

      -- Insert cell marker
      vim.keymap.set("n", "<leader>j%", function()
        local lines = { "", "", "# %%" }
        local row = vim.api.nvim_win_get_cursor(0)[1]
        vim.api.nvim_buf_set_lines(0, row, row, false, lines)
        vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
      end, { desc = "Insert Jupyter Cell Markers" })
    end,
    lazy = false, -- Always load, don't wait for filetype
  },

  -- Optional: Quarto support for .qmd files
  {
    "quarto-dev/quarto-nvim",
    dependencies = {
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    ft = { "quarto", "markdown" },
    opts = {
      lspFeatures = {
        enabled = true,
        languages = { "python", "r", "julia" },
        diagnostics = {
          enabled = true,
          triggers = { "BufWritePost" },
        },
        completion = {
          enabled = true,
        },
      },
      codeRunner = {
        enabled = true,
        default_method = "molten",
      },
    },
    keys = {
      { "<leader>qp", ":QuartoPreview<CR>", desc = "Quarto Preview", silent = true },
      { "<leader>qr", ":QuartoRun<CR>", desc = "Quarto Run Cell", silent = true },

      -- Convert .ipynb to .qmd
      {
        "<leader>qci",
        function()
          local current_file = vim.fn.expand("%:p")
          if current_file:match("%.ipynb$") then
            vim.cmd("!quarto convert " .. vim.fn.shellescape(current_file))
            local qmd_file = current_file:gsub("%.ipynb$", ".qmd")
            vim.notify("Converted to " .. qmd_file, vim.log.levels.INFO)
            -- Ask if user wants to open the .qmd file
            vim.defer_fn(function()
              local choice = vim.fn.confirm("Open " .. vim.fn.fnamemodify(qmd_file, ":t") .. "?", "&Yes\n&No", 1)
              if choice == 1 then
                vim.cmd("edit " .. vim.fn.fnameescape(qmd_file))
              end
            end, 500)
          else
            vim.notify("Not an .ipynb file", vim.log.levels.ERROR)
          end
        end,
        desc = "Convert ipynb to qmd",
        silent = true,
      },

      -- Convert .qmd to .ipynb
      {
        "<leader>qcq",
        function()
          local current_file = vim.fn.expand("%:p")
          if current_file:match("%.qmd$") then
            local output_file = current_file:gsub("%.qmd$", ".ipynb")
            local cmd = string.format(
              "!quarto convert %s --output %s",
              vim.fn.shellescape(current_file),
              vim.fn.shellescape(output_file)
            )
            vim.cmd(cmd)
            vim.notify("Converted to " .. vim.fn.fnamemodify(output_file, ":t"), vim.log.levels.INFO)
          else
            vim.notify("Not a .qmd file", vim.log.levels.ERROR)
          end
        end,
        desc = "Convert qmd to ipynb",
        silent = true,
      },
    },
  },

  -- Otter: LSP/completion in code blocks (for Quarto)
  {
    "jmbuhr/otter.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {},
  },

  -- Formatter for Jupyter notebooks and Python files
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        python = { "ruff_format", "ruff_organize_imports" },
        ipynb = { "ruff_format", "ruff_organize_imports" },
      },
    },
  },
}
