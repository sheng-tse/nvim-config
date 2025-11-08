return {
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = "VeryLazy",
    config = function()
      local rainbow_delimiters = require("rainbow-delimiters")

      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow_delimiters.strategy["global"],
          vim = rainbow_delimiters.strategy["local"],
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
        },
        highlight = {
          "RainbowDelimiter1",  -- Level 1 - Outermost
          "RainbowDelimiter2",  -- Level 2
          "RainbowDelimiter3",  -- Level 3
          "RainbowDelimiter4",  -- Level 4
          "RainbowDelimiter5",  -- Level 5
          "RainbowDelimiter6",  -- Level 6
          "RainbowDelimiter7",  -- Level 7
          "RainbowDelimiter8",  -- Level 8
          "RainbowDelimiter9",  -- Level 9
          "RainbowDelimiter10", -- Level 10 - Innermost
        },
      }

      -- Define 10 VERY DISTINCT colors for nested brackets
      -- Each level is clearly different from the next
      vim.api.nvim_set_hl(0, "RainbowDelimiter1", { fg = "#ff9e64", bold = true })  -- Level 1: Bright Orange
      vim.api.nvim_set_hl(0, "RainbowDelimiter2", { fg = "#7dcfff", bold = true })  -- Level 2: Cyan
      vim.api.nvim_set_hl(0, "RainbowDelimiter3", { fg = "#bb9af7", bold = true })  -- Level 3: Purple
      vim.api.nvim_set_hl(0, "RainbowDelimiter4", { fg = "#9ece6a", bold = true })  -- Level 4: Lime Green
      vim.api.nvim_set_hl(0, "RainbowDelimiter5", { fg = "#f7768e", bold = true })  -- Level 5: Pink/Coral
      vim.api.nvim_set_hl(0, "RainbowDelimiter6", { fg = "#e0af68", bold = true })  -- Level 6: Gold/Amber
      vim.api.nvim_set_hl(0, "RainbowDelimiter7", { fg = "#89ddff", bold = true })  -- Level 7: Sky Blue
      vim.api.nvim_set_hl(0, "RainbowDelimiter8", { fg = "#c3e88d", bold = true })  -- Level 8: Yellow-Green
      vim.api.nvim_set_hl(0, "RainbowDelimiter9", { fg = "#ff757f", bold = true })  -- Level 9: Salmon
      vim.api.nvim_set_hl(0, "RainbowDelimiter10", { fg = "#2ac3de", bold = true }) -- Level 10: Teal
    end,
  },
}
