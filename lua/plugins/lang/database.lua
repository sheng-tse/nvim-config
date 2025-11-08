return {
  -- DBUI: Database UI for querying databases
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod" },
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql", "pgsql" }, lazy = true },
    },
    cmd = {
      "DBUI",
      "DBUIToggle",
      "DBUIAddConnection",
      "DBUIFindBuffer",
      "DBUIRenameBuffer",
      "DBUILastQueryInfo",
    },
    keys = {
      { "<leader>db", "<cmd>DBUIToggle<CR>", desc = "Toggle Database UI" },
      { "<leader>df", "<cmd>DBUIFindBuffer<CR>", desc = "Find Database Buffer" },
      { "<leader>dr", "<cmd>DBUIRenameBuffer<CR>", desc = "Rename Database Buffer" },
      { "<leader>dl", "<cmd>DBUILastQueryInfo<CR>", desc = "Last Query Info" },
      { "<leader>da", "<cmd>DBUIAddConnection<CR>", desc = "Add Database Connection" },
    },
    config = function()
      -- Database UI settings
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_database_icon = 1
      vim.g.db_ui_force_echo_notifications = 1
      vim.g.db_ui_win_position = "left"
      vim.g.db_ui_winwidth = 40

      -- Auto-complete for SQL
      vim.g.db_ui_auto_execute_table_helpers = 1

      -- Save location for queries
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui_queries"

      -- PostgreSQL connection examples (uncomment and configure as needed):
      -- vim.g.dbs = {
      --   { name = 'local_postgres', url = 'postgresql://user:password@localhost:5432/database' },
      --   { name = 'dev_db', url = 'postgresql://user:password@dev-server:5432/database' },
      -- }
    end,
  },

  -- SQL formatting with pg_format
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        sql = { "pg_format" },
        pgsql = { "pg_format" },
      },
      formatters = {
        pg_format = {
          prepend_args = {
            "--function-case", "2",  -- lowercase function names
            "--keyword-case", "2",   -- uppercase keywords
            "--spaces", "2",         -- 2 spaces indentation
            "--no-extra-line",       -- remove extra blank lines
          },
        },
      },
    },
  },
}
