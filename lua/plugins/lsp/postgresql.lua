return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Postgres Language Server (Supabase)
        -- Uses Postgres' own parser for 100% syntax compatibility
        postgres_lsp = {
          filetypes = { "sql", "pgsql" },
          root_dir = function()
            return vim.loop.cwd()
          end,
        },
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "pgformatter",  -- PostgreSQL formatter
      },
    },
  },
}
