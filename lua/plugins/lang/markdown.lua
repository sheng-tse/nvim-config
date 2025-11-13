return {
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npm install",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown", "python", "ipynb" },
    init = function()
      -- IMPORTANT: These must be set BEFORE the plugin loads
      -- Enable preview for all files (not just markdown)
      vim.g.mkdp_command_for_global = 1

      -- Port for the preview server (default: random)
      vim.g.mkdp_port = ""

      -- Auto-start preview when entering markdown buffer (0: no, 1: yes)
      vim.g.mkdp_auto_start = 0

      -- Auto-close preview when leaving markdown buffer (0: no, 1: yes)
      vim.g.mkdp_auto_close = 1

      -- Refresh markdown on save or leaving insert mode (0: no, 1: yes)
      vim.g.mkdp_refresh_slow = 0

      -- Specify browser to open preview (empty: use system default)
      vim.g.mkdp_browser = ""

      -- Enable preview server available to others in network (0: no, 1: yes)
      vim.g.mkdp_open_to_the_world = 0

      -- Use custom IP to open preview (useful for remote work)
      vim.g.mkdp_open_ip = ""

      -- Echo preview page URL in command line (0: no, 1: yes)
      vim.g.mkdp_echo_preview_url = 0

      -- Custom function name for opening preview page
      vim.g.mkdp_browserfunc = ""

      -- Options for markdown rendering
      vim.g.mkdp_preview_options = {
        mkit = {},
        katex = {},
        uml = {},
        maid = {},
        disable_sync_scroll = 0,
        sync_scroll_type = "middle",
        hide_yaml_meta = 1,
        sequence_diagrams = {},
        flowchart_diagrams = {},
        content_editable = false,
        disable_filename = 0,
        toc = {},
      }

      -- Custom markdown CSS
      vim.g.mkdp_markdown_css = ""

      -- Custom highlight CSS
      vim.g.mkdp_highlight_css = ""

      -- Preview page title (${name} will be replaced with filename)
      vim.g.mkdp_page_title = "「${name}」"

      -- Use custom theme (empty string uses default, 'dark' or 'light')
      vim.g.mkdp_theme = "dark"

      -- Combine preview window (0: no, 1: yes - only for Windows)
      vim.g.mkdp_combine_preview = 0

      -- Auto-scroll in preview to follow cursor (0: no, 1: yes)
      vim.g.mkdp_combine_preview_auto_refresh = 1

      -- Recognized filetypes
      vim.g.mkdp_filetypes = { "markdown", "python", "ipynb" }
    end,
    keys = {
      {
        "<leader>mp",
        "<cmd>MarkdownPreview<CR>",
        desc = "Markdown Preview",
        silent = true,
      },
      {
        "<leader>ms",
        "<cmd>MarkdownPreviewStop<CR>",
        desc = "Markdown Preview Stop",
        silent = true,
      },
      {
        "<leader>mt",
        "<cmd>MarkdownPreviewToggle<CR>",
        desc = "Markdown Preview Toggle",
        silent = true,
      },
    },
  },
}
