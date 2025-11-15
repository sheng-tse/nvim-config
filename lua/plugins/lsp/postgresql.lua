return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Postgres Language Server (Supabase)
        -- Uses Postgres' own parser for 100% syntax compatibility
        -- Note: mason package name is "postgres-language-server"
        postgres_lsp = {
          mason = true, -- Explicitly use Mason for installation
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
        "postgres-language-server", -- Explicitly specify the correct package name
        "pgformatter",  -- PostgreSQL formatter
      },
    },
  },
}
