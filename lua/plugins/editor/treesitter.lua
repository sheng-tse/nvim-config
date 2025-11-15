return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- Add Java and other parsers to ensure_installed
      vim.list_extend(opts.ensure_installed or {}, {
        "java",
        "python",
        "lua",
        "javascript",
        "typescript",
        "c",
        "cpp",
        "rust",
        "go",
        "bash",
        "json",
        "yaml",
        "markdown",
        "sql",
      })

      -- Disable treesitter for LaTeX to allow VimTeX syntax detection to work
      -- This is required for UltiSnips math context detection (vimtex#syntax#in_mathzone)
      opts.highlight = opts.highlight or {}
      opts.highlight.disable = opts.highlight.disable or {}
      vim.list_extend(opts.highlight.disable, { "latex", "tex" })
    end,
  },
}
