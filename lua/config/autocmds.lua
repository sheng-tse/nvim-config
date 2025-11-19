-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Universal LSP semantic highlighting for all languages
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end

    -- Apply semantic token highlights for all languages except Lua (Lua uses Tree-sitter only)
    local langs = {
      "python",
      "cpp",
      "c",
      "java",
      "julia",
      "rust",
      "go",
      "typescript",
      "javascript",
      "sql",
      "plsql",
      "postgres",
    }

    for _, lang in ipairs(langs) do
      -- Comments - #f9f9f9 (light-gray) - Subtle, not too purple
      vim.api.nvim_set_hl(0, "@lsp.type.comment." .. lang, { fg = "#989898", italic = true })
      vim.api.nvim_set_hl(0, "@comment." .. lang, { fg = "#989898", italic = true })

      -- Strings - #9ece6a (lime green) - "/path/to/file" or "Number of ratings"
      vim.api.nvim_set_hl(0, "@string." .. lang, { fg = "#9ece6a" })
      vim.api.nvim_set_hl(0, "@lsp.type.string." .. lang, { fg = "#9ece6a" })

      -- Modules/Namespaces - #42A38F (blue-green) - "numpy" in import numpy as np
      vim.api.nvim_set_hl(0, "@lsp.type.namespace." .. lang, { fg = "#42A38F", italic = true })
      vim.api.nvim_set_hl(0, "@lsp.type.module." .. lang, { fg = "#42A38F", italic = true })

      -- Variables - #c3e88d (soft yellow-green) - "ind" in ind = np.arange() (DIFFERENT from np)
      vim.api.nvim_set_hl(0, "@lsp.type.variable." .. lang, { fg = "#c3e88d" })

      -- Imported modules as variables - #42A38F (blue-green) - "np", "pd", "plt" after import (VERY DIFFERENT from numpy orange)
      vim.api.nvim_set_hl(0, "@lsp.mod.defaultLibrary." .. lang, { fg = "#42A38F", italic = true })
      vim.api.nvim_set_hl(0, "@lsp.typemod.variable.defaultLibrary." .. lang, { fg = "#42A38F", italic = true })

      -- Parameters - #e0af68 (amber/gold) - Function parameters
      vim.api.nvim_set_hl(0, "@lsp.type.parameter." .. lang, { fg = "#e0af68" })

      -- Properties/Attributes - #c3e88d (yellow-green) - object.property (same as variables for consistency)
      vim.api.nvim_set_hl(0, "@lsp.type.property." .. lang, { fg = "#c3e88d" })

      -- Classes - #ffc777 (golden orange) - Class definitions (less blue/cyan)
      vim.api.nvim_set_hl(0, "@lsp.type.class." .. lang, { fg = "#ffc777", bold = true })
      vim.api.nvim_set_hl(0, "@lsp.type.struct." .. lang, { fg = "#ffc777", bold = true })

      -- Functions/Methods - #bb9af7 (purple) - "arange" in np.arange() (DIFFERENT from np)
      vim.api.nvim_set_hl(0, "@lsp.type.function." .. lang, { fg = "#bb9af7" })
      vim.api.nvim_set_hl(0, "@lsp.type.method." .. lang, { fg = "#bb9af7" })

      -- Types - #86e1fc (sky blue) - Type annotations like int, str, List[str]
      vim.api.nvim_set_hl(0, "@lsp.type.type." .. lang, { fg = "#86e1fc" })
      vim.api.nvim_set_hl(0, "@lsp.type.interface." .. lang, { fg = "#86e1fc" })

      -- Enums - #c099ff (lavender) - Enum types (ONE purple accent)
      vim.api.nvim_set_hl(0, "@lsp.type.enum." .. lang, { fg = "#c099ff" })
      vim.api.nvim_set_hl(0, "@lsp.type.enumMember." .. lang, { fg = "#ff9e64" }) -- (peach) - Enum values

      -- Macros - #ff757f (coral) - C/C++ preprocessor macros
      vim.api.nvim_set_hl(0, "@lsp.type.macro." .. lang, { fg = "#ff757f" })

      -- Keyword void - #f7768e (tokyonight red) - void in public static void main()
      vim.api.nvim_set_hl(0, "@keyword.void." .. lang, { fg = "#f7768e", bold = true })

      -- Main function name - #9d7cd8 (tokyonight dark purple) - main in public static void main()
      vim.api.nvim_set_hl(0, "@function.main." .. lang, { fg = "#9d7cd8", bold = true })

      -- Method calls only (.*()) - #9683EC (purple) - clientSocket.getOutputStream()
      vim.api.nvim_set_hl(0, "@lsp.type.method.call." .. lang, { fg = "#9683EC" })
      vim.api.nvim_set_hl(0, "@lsp.typemod.method.call." .. lang, { fg = "#9683EC" })
    end

    -- Operators - #89ddff (bright cyan) - + - * / = < >
    vim.api.nvim_set_hl(0, "@operator", { fg = "#89ddff" })

    -- Delimiters - #ff757f (coral) - , ; .
    vim.api.nvim_set_hl(0, "@punctuation.delimiter", { fg = "#ff757f" })

    -- Matching parentheses highlight (when cursor is on a bracket)
    vim.api.nvim_set_hl(0, "MatchParen", { fg = "#f7768e", bg = "#3b4261", bold = true })

    -- Lua-specific: Disable LSP semantic tokens, use Tree-sitter only
    if client.name == "lua_ls" then
      client.server_capabilities.semanticTokensProvider = nil
    end

    -- Python-specific: Set conda environment
    if client.name == "basedpyright" or client.name == "pyright" then
      local conda_prefix = vim.env.CONDA_PREFIX
      if conda_prefix then
        local python_path = conda_prefix .. "/bin/python"
        client.config.settings = vim.tbl_deep_extend("force", client.config.settings or {}, {
          python = {
            pythonPath = python_path,
          },
        })
        client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
        vim.notify("LSP using Python from: " .. conda_prefix, vim.log.levels.INFO)
      end
    end
  end,
})

-- Enhance syntax highlighting for all languages via Tree-sitter
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    -- All supported languages
    local langs = {
      "python",
      "cpp",
      "c",
      "java",
      "julia",
      "rust",
      "go",
      "typescript",
      "javascript",
      "lua",
      "sql",
      "plsql",
    }

    for _, lang in ipairs(langs) do
      -- Comments - #989898 (light-gray) - Subtle, not too purple
      vim.api.nvim_set_hl(0, "@comment." .. lang, { fg = "#989898", italic = true })

      -- Strings - #9ece6a (lime green) - "Number of ratings" or "/path/to/file"
      vim.api.nvim_set_hl(0, "@string." .. lang, { fg = "#9ece6a" })

      -- Keywords (import, include, using, etc.)
      vim.api.nvim_set_hl(0, "@keyword.import." .. lang, { link = "Include" })
      vim.api.nvim_set_hl(0, "@keyword." .. lang, { link = "Keyword" })
      vim.api.nvim_set_hl(0, "@keyword.repeat." .. lang, { link = "Repeat" })
      vim.api.nvim_set_hl(0, "@keyword.conditional." .. lang, { link = "Conditional" })

      -- Built-ins
      vim.api.nvim_set_hl(0, "@variable.builtin." .. lang, { link = "Special" })
      vim.api.nvim_set_hl(0, "@type.builtin." .. lang, { link = "Type" })

      -- Modules/Namespaces - #42A38F (blue-green) - "numpy" in import numpy as np
      vim.api.nvim_set_hl(0, "@module." .. lang, { fg = "#42A38F", italic = true })
      vim.api.nvim_set_hl(0, "@namespace." .. lang, { fg = "#42A38F", italic = true })

      -- Variables - #c3e88d (soft yellow-green) - "ind" in ind = np.arange()
      vim.api.nvim_set_hl(0, "@variable." .. lang, { fg = "#c3e88d" })
      vim.api.nvim_set_hl(0, "@variable.member." .. lang, { fg = "#c3e88d" }) -- member vars (same as variables)

      -- Constants and parameters
      vim.api.nvim_set_hl(0, "@constant." .. lang, { fg = "#ff9e64" }) -- (peach) - Constants
      vim.api.nvim_set_hl(0, "@parameter." .. lang, { fg = "#e0af68" }) -- (amber) - Parameters

      -- Functions and methods - #bb9af7 (purple) - "arange" in np.arange()
      vim.api.nvim_set_hl(0, "@function." .. lang, { fg = "#bb9af7" })
      vim.api.nvim_set_hl(0, "@method." .. lang, { fg = "#bb9af7" })

      -- Method calls only (.*()) - #9683EC (purple) - clientSocket.getOutputStream()
      vim.api.nvim_set_hl(0, "@method.call." .. lang, { fg = "#9683EC" })

      -- Keyword void - #f7768e (tokyonight red) - void in public static void main()
      vim.api.nvim_set_hl(0, "@keyword.void." .. lang, { fg = "#f7768e", bold = true })

      -- Main function name - #9d7cd8 (tokyonight dark purple) - main in public static void main()
      vim.api.nvim_set_hl(0, "@function.main." .. lang, { fg = "#9d7cd8", bold = true })

      -- Types and classes - #7dcfff (cyan) / #ffc777 (golden orange) - Better differentiated
      vim.api.nvim_set_hl(0, "@type." .. lang, { fg = "#7dcfff" })
      vim.api.nvim_set_hl(0, "@class." .. lang, { fg = "#ffc777", bold = true })
    end

    -- Global highlight groups (non-language-specific)
    -- Method calls only (.*()) - #9683EC (purple)
    vim.api.nvim_set_hl(0, "@method.call", { fg = "#9683EC" })
    vim.api.nvim_set_hl(0, "@lsp.type.method.call", { fg = "#9683EC" })

    -- Make sure base groups have distinct colors
    local keyword = vim.api.nvim_get_hl(0, { name = "Keyword" })
    if not keyword.fg then
      vim.api.nvim_set_hl(0, "Keyword", { fg = "#bb9af7", bold = true }) -- Purple
      vim.api.nvim_set_hl(0, "Include", { fg = "#ff757f", bold = true }) -- Pink/Red
    end

    -- Apply void and main colors LAST to ensure they override defaults
    vim.defer_fn(function()
      vim.api.nvim_set_hl(0, "@keyword.void", { fg = "#f7768e", bold = true })
      vim.api.nvim_set_hl(0, "@function.main", { fg = "#9d7cd8", bold = true })
    end, 10)
  end,
})

-- Trigger the highlight setup for the current colorscheme
vim.cmd("doautocmd ColorScheme")

-- Ensure void and main highlighting is applied for all file types
vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    vim.defer_fn(function()
      -- Apply globally without language-specific suffixes
      vim.api.nvim_set_hl(0, "@keyword.void", { fg = "#f7768e", bold = true })
      vim.api.nvim_set_hl(0, "@function.main", { fg = "#9d7cd8", bold = true })
      vim.api.nvim_set_hl(0, "@method.call", { fg = "#9683EC" })
    end, 100)
  end,
})

-- Handle swap file conflicts automatically
-- When a swap file is detected, automatically choose to open read-only or recover
vim.api.nvim_create_autocmd("SwapExists", {
  callback = function()
    -- Set to 'o' for read-only, 'r' to recover, 'q' to quit, 'a' to abort
    vim.v.swapchoice = "o" -- Open read-only by default
    vim.notify("Swap file detected - opening read-only", vim.log.levels.WARN)
  end,
})
