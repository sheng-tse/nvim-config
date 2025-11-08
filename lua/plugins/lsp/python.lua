return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        basedpyright = {
          filetypes = { "python" },
          settings = {
            basedpyright = {
              -- Type checking mode
              typeCheckingMode = "standard", -- "off", "basic", "standard", "strict"

              -- Disable overly aggressive checks
              disableOrganizeImports = false,

              analysis = {
                -- Auto-import completions
                autoImportCompletions = true,
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,

                -- Diagnostics
                diagnosticMode = "openFilesOnly", -- Don't check entire workspace

                -- Type stub packages
                stubPath = "typings",

                -- Diagnostic severity overrides
                diagnosticSeverityOverrides = {
                  -- Reduce noise from common patterns
                  reportUnknownParameterType = "none",
                  reportUnknownArgumentType = "none",
                  reportUnknownVariableType = "none",
                  reportUnknownMemberType = "none",
                  reportMissingTypeStubs = "none",
                  reportUnknownLambdaType = "none",
                  reportUnusedVariable = "warning",
                  reportUnusedImport = "warning",

                  -- Jupyter/interactive patterns
                  reportMissingImports = "warning",
                  reportUndefinedVariable = "warning",

                  -- Be more lenient with type checking
                  reportGeneralTypeIssues = "none",
                  reportOptionalMemberAccess = "none",
                  reportOptionalSubscript = "none",
                  reportPrivateImportUsage = "none",
                },
              },
            },
          },
        },
      },
    },
  },
}
