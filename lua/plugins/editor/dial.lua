return {
  "monaqa/dial.nvim",
  keys = {
    {
      "<C-a>",
      function()
        return require("dial.map").inc_normal()
      end,
      expr = true,
      desc = "Increment",
    },
    {
      "<C-x>",
      function()
        return require("dial.map").dec_normal()
      end,
      expr = true,
      desc = "Decrement",
    },
    {
      "<C-a>",
      function()
        return require("dial.map").inc_visual()
      end,
      mode = "v",
      expr = true,
      desc = "Increment",
    },
    {
      "<C-x>",
      function()
        return require("dial.map").dec_visual()
      end,
      mode = "v",
      expr = true,
      desc = "Decrement",
    },
    {
      "g<C-a>",
      function()
        return require("dial.map").inc_gvisual()
      end,
      mode = "v",
      expr = true,
      desc = "Increment (sequential)",
    },
    {
      "g<C-x>",
      function()
        return require("dial.map").dec_gvisual()
      end,
      mode = "v",
      expr = true,
      desc = "Decrement (sequential)",
    },
  },
  config = function()
    local augend = require("dial.augend")

    require("dial.config").augends:register_group({
      default = {
        -- Numbers
        augend.integer.alias.decimal, -- 0, 1, 2, ...
        augend.integer.alias.hex, -- 0x00, 0x01, ...
        augend.integer.alias.octal, -- 0o00, 0o01, ...
        augend.integer.alias.binary, -- 0b00, 0b01, ...

        -- Dates
        augend.date.alias["%Y/%m/%d"], -- 2024/01/15
        augend.date.alias["%Y-%m-%d"], -- 2024-01-15
        augend.date.alias["%m/%d/%Y"], -- 01/15/2024
        augend.date.alias["%H:%M:%S"], -- 14:30:00
        augend.date.alias["%H:%M"], -- 14:30

        -- Booleans
        augend.constant.alias.bool, -- true/false

        -- Comparison operators
        augend.constant.new({
          elements = { "==", "!=" },
          word = false,
          cyclic = true,
        }),
        augend.constant.new({
          elements = { "===", "!==" },
          word = false,
          cyclic = true,
        }),

        -- Logical operators
        augend.constant.new({
          elements = { "&&", "||" },
          word = false,
          cyclic = true,
        }),
        augend.constant.new({
          elements = { "and", "or" },
          word = true,
          cyclic = true,
        }),

        -- Relational operators
        augend.constant.new({
          elements = { ">", "<", ">=", "<=" },
          word = false,
          cyclic = true,
        }),

        -- Math operators
        augend.constant.new({
          elements = { "+", "-", "*", "/" },
          word = false,
          cyclic = true,
        }),

        -- Boolean words (various cases)
        augend.constant.new({
          elements = { "True", "False" },
          word = true,
          cyclic = true,
        }),
        augend.constant.new({
          elements = { "TRUE", "FALSE" },
          word = true,
          cyclic = true,
        }),
        augend.constant.new({
          elements = { "yes", "no" },
          word = true,
          cyclic = true,
        }),
        augend.constant.new({
          elements = { "Yes", "No" },
          word = true,
          cyclic = true,
        }),
        augend.constant.new({
          elements = { "YES", "NO" },
          word = true,
          cyclic = true,
        }),

        -- Days of the week
        augend.constant.new({
          elements = { "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" },
          word = true,
          cyclic = true,
        }),
        augend.constant.new({
          elements = { "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun" },
          word = true,
          cyclic = true,
        }),

        -- Months
        augend.constant.new({
          elements = {
            "January",
            "February",
            "March",
            "April",
            "May",
            "June",
            "July",
            "August",
            "September",
            "October",
            "November",
            "December",
          },
          word = true,
          cyclic = true,
        }),
        augend.constant.new({
          elements = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" },
          word = true,
          cyclic = true,
        }),

        -- Git conflict markers
        augend.constant.new({
          elements = { "<<<<<<< HEAD", "=======", ">>>>>>>" },
          word = false,
          cyclic = true,
        }),

        -- Hex colors
        augend.hexcolor.new({
          case = "lower",
        }),

        -- Case styles (semver)
        augend.semver.alias.semver, -- 1.2.3 -> 1.2.4
      },
    })
  end,
}
