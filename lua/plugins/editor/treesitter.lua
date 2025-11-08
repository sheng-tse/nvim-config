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
    end,
  },
}
