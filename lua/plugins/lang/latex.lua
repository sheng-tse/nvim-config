return {
  -- VimTeX for LaTeX support
  {
    "lervag/vimtex",
    lazy = false, -- Load immediately for .tex files
    ft = "tex",
    config = function()
      -- Set the PDF viewer to Skim (macOS alternative to Zathura)
      vim.g.vimtex_view_method = "skim"
      vim.g.vimtex_view_skim_sync = 1
      vim.g.vimtex_view_skim_activate = 1

      -- Enable automatic viewer reload on file save
      vim.g.vimtex_view_automatic = 1

      -- Compiler settings - use latexmk with continuous mode
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_compiler_latexmk = {
        build_dir = "",  -- Use global .latexmkrc settings
        callback = 1,
        continuous = 1,
        executable = "latexmk",
        options = {
          "-pdf",
          "-verbose",
          "-file-line-error",
          "-synctex=1",
          "-interaction=nonstopmode",
        },
      }

      -- Enable concealment for cleaner editing (hides LaTeX syntax)
      vim.opt.conceallevel = 2
      vim.g.vimtex_syntax_conceal = {
        accents = 1,
        ligatures = 1,
        cites = 1,
        fancy = 1,
        spacing = 1,
        greek = 1,
        math_bounds = 1,
        math_delimiters = 1,
        math_fracs = 1,
        math_super_sub = 1,
        math_symbols = 1,
        sections = 0,
        styles = 1,
      }

      -- Quickfix window settings
      vim.g.vimtex_quickfix_mode = 0

      -- Disable overfull/underfull warnings
      vim.g.vimtex_quickfix_ignore_filters = {
        "Overfull",
        "Underfull",
      }

      -- Table of contents settings
      vim.g.vimtex_toc_config = {
        name = "TOC",
        layers = { "content", "todo", "include" },
        split_width = 30,
        todo_sorted = 0,
        show_help = 1,
        show_numbers = 1,
      }

      -- Spell checking for LaTeX files
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "tex",
        callback = function()
          vim.opt_local.spell = true
          vim.opt_local.spelllang = { "en_us" }
        end,
      })

      -- Keybinding: Ctrl+L to fix last spelling mistake
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "tex",
        callback = function()
          vim.keymap.set("i", "<C-l>", "<c-g>u<Esc>[s1z=`]a<c-g>u", {
            buffer = true,
            desc = "Fix last spelling mistake",
          })
        end,
      })

      -- Word count function for LaTeX
      vim.api.nvim_create_user_command("WordCount", function()
        local file = vim.fn.expand("%:p")
        local output = vim.fn.system("texcount -brief " .. file)
        print(output)
      end, {})

      -- Inkscape figures integration (Ctrl+F to create/edit figures)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "tex",
        callback = function()
          -- Ctrl+F in insert mode: create new figure
          vim.keymap.set("i", "<C-f>", function()
            vim.ui.input({ prompt = "Figure name: " }, function(name)
              if name then
                local root = vim.fn.expand("%:p:h")
                vim.fn.system("inkscape-figures create '" .. name .. "' '" .. root .. "/figures/'")
              end
            end)
          end, { buffer = true, desc = "Create new Inkscape figure" })

          -- Ctrl+F in normal mode: edit existing figure
          vim.keymap.set("n", "<C-f>", function()
            local root = vim.fn.expand("%:p:h")
            vim.fn.system("inkscape-figures edit '" .. root .. "/figures/'")
          end, { buffer = true, desc = "Edit Inkscape figure" })
        end,
      })
    end,
  },

  -- UltiSnips for snippet expansion
  {
    "SirVer/ultisnips",
    dependencies = {
      "honza/vim-snippets", -- Optional: collection of common snippets
    },
    config = function()
      -- Trigger configuration
      vim.g.UltiSnipsExpandTrigger = "<tab>"
      vim.g.UltiSnipsJumpForwardTrigger = "<tab>"
      vim.g.UltiSnipsJumpBackwardTrigger = "<s-tab>"

      -- Snippet directories
      vim.g.UltiSnipsSnippetDirectories = { "UltiSnips" }

      -- Split window for editing snippets
      vim.g.UltiSnipsEditSplit = "vertical"
    end,
  },
}
