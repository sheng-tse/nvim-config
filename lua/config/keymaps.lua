-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Java-specific keymaps (only active in Java files)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function()
    local opts = { buffer = true, silent = true }

    -- Detect if project uses Maven or Gradle
    local function is_maven_project()
      return vim.fn.filereadable("pom.xml") == 1 or vim.fn.filereadable("mvnw") == 1
    end

    local function is_gradle_project()
      return vim.fn.filereadable("build.gradle") == 1 or vim.fn.filereadable("build.gradle.kts") == 1 or vim.fn.filereadable("gradlew") == 1
    end

    if is_maven_project() then
      -- Maven keymaps
      vim.keymap.set("n", "<leader>jb", ":terminal mvn compile<CR>",
        vim.tbl_extend("force", opts, { desc = "Java: Build (Maven)" }))

      vim.keymap.set("n", "<leader>jr", function()
        local current_file = vim.fn.expand("%:t:r") -- Get class name
        local package_name = ""
        local has_main = false

        -- Read current file to check for main method and package
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        for _, line in ipairs(lines) do
          -- Check for package declaration
          local pkg = line:match("^%s*package%s+([%w%.]+)%s*;")
          if pkg then
            package_name = pkg
          end

          -- Check for main method
          if line:match("public%s+static%s+void%s+main") then
            has_main = true
          end
        end

        -- If current file has main, run it directly
        if has_main then
          local fully_qualified = package_name ~= "" and (package_name .. "." .. current_file) or current_file
          vim.cmd("terminal mvn exec:java -Dexec.mainClass=" .. fully_qualified)
        else
          -- Otherwise, use default config (will fail with helpful error if not configured)
          vim.cmd("terminal mvn exec:java")
        end
      end, vim.tbl_extend("force", opts, { desc = "Java: Run Current or Default (Maven)" }))

      vim.keymap.set("n", "<leader>jt", ":terminal mvn test<CR>",
        vim.tbl_extend("force", opts, { desc = "Java: Test (Maven)" }))

      vim.keymap.set("n", "<leader>jc", ":terminal mvn clean compile<CR>",
        vim.tbl_extend("force", opts, { desc = "Java: Clean Build (Maven)" }))

      vim.keymap.set("n", "<leader>jp", ":terminal mvn package<CR>",
        vim.tbl_extend("force", opts, { desc = "Java: Package (Maven)" }))

    elseif is_gradle_project() then
      -- Gradle keymaps
      vim.keymap.set("n", "<leader>jb", ":terminal ./gradlew build<CR>",
        vim.tbl_extend("force", opts, { desc = "Java: Build (Gradle)" }))

      vim.keymap.set("n", "<leader>jr", ":terminal ./gradlew run<CR>",
        vim.tbl_extend("force", opts, { desc = "Java: Run (Gradle)" }))

      vim.keymap.set("n", "<leader>jt", ":terminal ./gradlew test<CR>",
        vim.tbl_extend("force", opts, { desc = "Java: Test (Gradle)" }))

      vim.keymap.set("n", "<leader>jc", ":terminal ./gradlew clean build<CR>",
        vim.tbl_extend("force", opts, { desc = "Java: Clean Build (Gradle)" }))

      -- Smart run current Java file (detects class name and runs it)
      vim.keymap.set("n", "<leader>jR", function()
        local filename = vim.fn.expand("%:t:r") -- Get filename without extension
        vim.cmd("terminal ./gradlew run" .. filename)
      end, vim.tbl_extend("force", opts, { desc = "Java: Run Current Class (Gradle)" }))
    else
      -- Simple Java project (no build tool) - typical IntelliJ setup
      -- Supports both packages and non-packaged classes

      vim.keymap.set("n", "<leader>jb", function()
        local project_root = vim.fn.getcwd()
        vim.cmd("terminal cd " .. project_root .. " && find src -name '*.java' | xargs javac -d out")
      end, vim.tbl_extend("force", opts, { desc = "Java: Build (Simple)" }))

      vim.keymap.set("n", "<leader>jr", function()
        local project_root = vim.fn.getcwd()
        local filename = vim.fn.expand("%:t:r") -- Get class name from current file

        -- Read current file to detect package declaration
        local lines = vim.api.nvim_buf_get_lines(0, 0, 20, false) -- Read first 20 lines
        local package_name = nil
        for _, line in ipairs(lines) do
          local pkg = line:match("^%s*package%s+([%w%.]+)%s*;")
          if pkg then
            package_name = pkg
            break
          end
        end

        -- Build fully qualified class name
        local class_name = package_name and (package_name .. "." .. filename) or filename

        vim.cmd("terminal cd " .. project_root .. " && find src -name '*.java' | xargs javac -d out && java -cp out " .. class_name)
      end, vim.tbl_extend("force", opts, { desc = "Java: Run Current Class (Simple)" }))

      vim.keymap.set("n", "<leader>jc", function()
        local project_root = vim.fn.getcwd()
        vim.cmd("terminal cd " .. project_root .. " && rm -rf out && mkdir -p out && find src -name '*.java' | xargs javac -d out")
      end, vim.tbl_extend("force", opts, { desc = "Java: Clean Build (Simple)" }))
    end

    -- Quick compile current file (works for all)
    vim.keymap.set("n", "<leader>jk", ":!javac %<CR>",
      vim.tbl_extend("force", opts, { desc = "Java: Compile current file" }))
  end,
})

-- Helper function to create new Java class with proper package
local function create_java_class()
  local cwd = vim.fn.getcwd()
  local src_main = cwd .. "/app/src/main/java/"
  local src_test = cwd .. "/app/src/test/java/"

  -- Ask user for class name and type
  local class_name = vim.fn.input("Class name: ")
  if class_name == "" then return end

  local choices = { "1. Main source (app/src/main/java/)", "2. Test source (app/src/test/java/)" }
  local choice = vim.fn.inputlist(choices)

  local base_path = choice == 2 and src_test or src_main

  -- Ask for package (optional)
  local package = vim.fn.input("Package (e.g., com.example.util or leave empty): ")

  local file_path
  if package ~= "" then
    -- Convert package to path (com.example.util -> com/example/util)
    local package_path = package:gsub("%.", "/")
    local full_path = base_path .. package_path
    vim.fn.mkdir(full_path, "p")
    file_path = full_path .. "/" .. class_name .. ".java"
  else
    file_path = base_path .. class_name .. ".java"
  end

  -- Create and open the file
  vim.cmd("edit " .. file_path)

  -- Insert package declaration and class template
  local lines = {}
  if package ~= "" then
    table.insert(lines, "package " .. package .. ";")
    table.insert(lines, "")
  end
  table.insert(lines, "public class " .. class_name .. " {")
  table.insert(lines, "    ")
  table.insert(lines, "}")

  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.cmd("normal! 3Gzz") -- Jump to line 3 (inside class)
end

-- Keymap to create new Java class
vim.keymap.set("n", "<leader>jn", create_java_class, { desc = "Java: New Class" })
