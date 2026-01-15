return {
  -- Disable nvim-lspconfig's automatic jdtls setup to prevent duplicate servers
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        jdtls = {},
      },
      setup = {
        jdtls = function()
          return true -- Tells lspconfig: "Don't setup jdtls, I'm handling it myself"
        end,
      },
    },
  },
  {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    config = function()
      local jdtls = require("jdtls")

      -- Function to setup jdtls when Java file is opened
      local function setup_jdtls()
        local jdtls_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
        local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
        local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspaces/" .. project_name

        -- Ensure workspace directory exists
        vim.fn.mkdir(workspace_dir, "p")

        -- Find root directory (looks for gradle, maven, or git)
        -- IMPORTANT: Check for multi-project root FIRST (settings.gradle*), then fall back to other markers
        local root_dir = require("jdtls.setup").find_root({ "settings.gradle.kts", "settings.gradle" })
          or require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml" })
          or require("jdtls.setup").find_root({ "build.gradle", "build.gradle.kts" })

        -- Detect platform for jdtls config directory
        local function get_jdtls_config_dir()
          local uname = vim.loop.os_uname()
          if uname.sysname == "Darwin" then
            -- macOS: check architecture
            if uname.machine == "arm64" then
              return jdtls_path .. "/config_mac_arm"
            else
              return jdtls_path .. "/config_mac"
            end
          elseif uname.sysname == "Linux" then
            return jdtls_path .. "/config_linux"
          elseif uname.sysname:match("Windows") then
            return jdtls_path .. "/config_win"
          end
          -- Fallback: try to find any config directory
          for _, cfg in ipairs({ "config_mac_arm", "config_mac", "config_linux", "config_win" }) do
            if vim.fn.isdirectory(jdtls_path .. "/" .. cfg) == 1 then
              return jdtls_path .. "/" .. cfg
            end
          end
          return jdtls_path .. "/config_linux"  -- Default fallback
        end

        local config_dir = get_jdtls_config_dir()

        -- Java command and launcher
        local launcher_jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")

        -- Get capabilities from cmp-nvim-lsp (includes diagnostics support)
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        if pcall(require, "cmp_nvim_lsp") then
          capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
        end

        local config = {
          cmd = {
            "java",
            "-Declipse.application=org.eclipse.jdt.ls.core.id1",
            "-Dosgi.bundles.defaultStartLevel=4",
            "-Declipse.product=org.eclipse.jdt.ls.core.product",
            "-Dlog.protocol=true",
            "-Dlog.level=ALL",
            "-Xms1g",
            "-Xmx2g",
            "--add-modules=ALL-SYSTEM",
            "--add-opens",
            "java.base/java.util=ALL-UNNAMED",
            "--add-opens",
            "java.base/java.lang=ALL-UNNAMED",
            "-jar",
            launcher_jar,
            "-configuration",
            config_dir,
            "-data",
            workspace_dir,
          },
          root_dir = root_dir,
          capabilities = capabilities,
          settings = {
            java = {
              eclipse = {
                downloadSources = true,
              },
              configuration = {
                updateBuildConfiguration = "interactive",
              },
              maven = {
                downloadSources = true,
              },
              implementationsCodeLens = {
                enabled = true,
              },
              referencesCodeLens = {
                enabled = true,
              },
              references = {
                includeDecompiledSources = true,
              },
              format = {
                enabled = true,
              },
              signatureHelp = {
                enabled = true,
              },
              contentProvider = {
                preferred = "fernflower",
              },
              completion = {
                favoriteStaticMembers = {
                  "org.junit.jupiter.api.Assertions.*",
                  "org.junit.Assert.*",
                  "org.mockito.Mockito.*",
                  "java.util.Objects.requireNonNull",
                  "java.util.Objects.requireNonNullElse",
                },
                filteredTypes = {
                  "com.sun.*",
                  "io.micrometer.shaded.*",
                  "java.awt.*",
                  "jdk.*",
                  "sun.*",
                },
                importOrder = {
                  "java",
                  "javax",
                  "com",
                  "org",
                },
              },
              sources = {
                organizeImports = {
                  starThreshold = 9999,
                  staticStarThreshold = 9999,
                },
              },
              codeGeneration = {
                toString = {
                  template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
                },
                useBlocks = true,
              },
              inlayHints = {
                parameterNames = {
                  enabled = "all", -- "none", "literals", or "all"
                },
              },
            },
          },
          init_options = {
            bundles = {},
          },
          on_attach = function(client, bufnr)
            -- Setup DAP (debugger)
            jdtls.setup_dap({ hotcodereplace = "auto" })

            -- Enable inlay hints for Java with error protection
            -- Wrap in pcall to prevent decoration provider errors from interrupting workflow
            -- if client.server_capabilities.inlayHintProvider then
            --   pcall(function()
            --     vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
            --   end)
            -- end
            vim.defer_fn(function()
              if client.server_capabilities.inlayHintProvider then
                pcall(vim.lsp.inlay_hint, bufnr, true)
              end
            end, 100)

            -- Java-specific keymaps
            local opts = { buffer = bufnr, silent = true }

            -- Organize imports
            vim.keymap.set(
              "n",
              "<leader>co",
              jdtls.organize_imports,
              vim.tbl_extend("force", opts, { desc = "Organize Imports" })
            )

            -- Extract variable
            vim.keymap.set(
              "n",
              "<leader>cv",
              jdtls.extract_variable,
              vim.tbl_extend("force", opts, { desc = "Extract Variable" })
            )
            vim.keymap.set(
              "v",
              "<leader>cv",
              [[<ESC><CMD>lua require('jdtls').extract_variable(true)<CR>]],
              vim.tbl_extend("force", opts, { desc = "Extract Variable" })
            )

            -- Extract constant
            vim.keymap.set(
              "n",
              "<leader>cC",
              jdtls.extract_constant,
              vim.tbl_extend("force", opts, { desc = "Extract Constant" })
            )
            vim.keymap.set(
              "v",
              "<leader>cC",
              [[<ESC><CMD>lua require('jdtls').extract_constant(true)<CR>]],
              vim.tbl_extend("force", opts, { desc = "Extract Constant" })
            )

            -- Extract method
            vim.keymap.set(
              "v",
              "<leader>cm",
              [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]],
              vim.tbl_extend("force", opts, { desc = "Extract Method" })
            )

            -- Test commands
            vim.keymap.set("n", "<leader>tc", jdtls.test_class, vim.tbl_extend("force", opts, { desc = "Test Class" }))
            vim.keymap.set(
              "n",
              "<leader>tm",
              jdtls.test_nearest_method,
              vim.tbl_extend("force", opts, { desc = "Test Nearest Method" })
            )

            -- Toggle inlay hints (useful if you want to turn them on/off)
            vim.keymap.set("n", "<leader>th", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
            end, vim.tbl_extend("force", opts, { desc = "Toggle Inlay Hints" }))

            -- General LSP keymaps (if not already set by LazyVim)
            vim.keymap.set(
              "n",
              "gD",
              vim.lsp.buf.declaration,
              vim.tbl_extend("force", opts, { desc = "Go to Declaration" })
            )
            vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover Documentation" }))
          end,
        }

        -- Start or attach to jdtls
        jdtls.start_or_attach(config)
      end

      -- Auto-setup jdtls for Java files
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = setup_jdtls,
      })
    end,
  },
  {
    "mfussenegger/nvim-dap",
    optional = true,
  },
}
