return {
  -- Enable semantic highlighting from LSP
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Initialize servers table if it doesn't exist
      opts.servers = opts.servers or {}

      -- Configure capabilities for all servers using the wildcard '*'
      opts.servers["*"] = opts.servers["*"] or {}
      opts.servers["*"].capabilities = opts.servers["*"].capabilities or vim.lsp.protocol.make_client_capabilities()

      -- Enable semantic tokens client capability (this gets merged before LSP servers configure themselves)
      opts.servers["*"].capabilities.textDocument = opts.servers["*"].capabilities.textDocument or {}
      opts.servers["*"].capabilities.textDocument.semanticTokens = {
        dynamicRegistration = false,
        requests = {
          full = {
            delta = true,
          },
          range = true,
        },
        tokenTypes = {
          "namespace",
          "type",
          "class",
          "enum",
          "interface",
          "struct",
          "typeParameter",
          "parameter",
          "variable",
          "property",
          "enumMember",
          "event",
          "function",
          "method",
          "macro",
          "keyword",
          "modifier",
          "comment",
          "string",
          "number",
          "regexp",
          "operator",
        },
        tokenModifiers = {
          "declaration",
          "definition",
          "readonly",
          "static",
          "deprecated",
          "abstract",
          "async",
          "modification",
          "documentation",
          "defaultLibrary",
        },
        formats = { "relative" },
        overlappingTokenSupport = false,
        multilineTokenSupport = false,
      }
      return opts
    end,
  },

  -- Enhanced Tree-sitter highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = {
        enable = true,
      },
    },
  },
}
