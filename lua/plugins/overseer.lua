-- overseer.nvim - Unified task runner for C++, CMake, Java, and more
-- Flexible setup that handles simple files and complex projects

return {
  {
    "stevearc/overseer.nvim",
    lazy = false, -- Load immediately to ensure templates are registered
    opts = {
      templates = { "builtin" },
      task_list = {
        direction = "bottom",
        min_height = 10,
        max_height = 25,
        bindings = {
          ["?"] = "ShowHelp",
          ["<CR>"] = "RunAction",
          ["<C-e>"] = "Edit",
          ["o"] = "Open",
          ["<C-v>"] = "OpenVsplit",
          ["<C-s>"] = "OpenSplit",
          ["<C-f>"] = "OpenFloat",
          ["<C-q>"] = "OpenQuickFix",
          ["q"] = "Close",
        },
      },
      -- Use terminal for interactive programs
      strategy = "terminal",
    },
    config = function(_, opts)
      local overseer = require("overseer")
      overseer.setup(opts)

      -- ========================================
      -- HELPER FUNCTIONS
      -- ========================================

      -- Find project root by looking for markers
      local function find_project_root(markers)
        local path = vim.fn.expand("%:p:h")
        while path ~= "/" do
          for _, marker in ipairs(markers) do
            if vim.fn.filereadable(path .. "/" .. marker) == 1 or vim.fn.isdirectory(path .. "/" .. marker) == 1 then
              return path
            end
          end
          path = vim.fn.fnamemodify(path, ":h")
        end
        return nil
      end

      -- Detect Java project type and root
      local function detect_java_project()
        -- Check for Maven
        local maven_root = find_project_root({ "pom.xml" })
        if maven_root then
          return "maven", maven_root
        end

        -- Check for Gradle - prioritize settings.gradle/gradlew (indicates true root for multi-module)
        local gradle_root = find_project_root({ "settings.gradle", "settings.gradle.kts", "gradlew" })
        if gradle_root then
          return "gradle", gradle_root
        end

        -- Fallback: single-module Gradle project (only has build.gradle)
        local gradle_single = find_project_root({ "build.gradle", "build.gradle.kts" })
        if gradle_single then
          return "gradle", gradle_single
        end

        -- Simple project - look for src directory
        local src_root = find_project_root({ "src" })
        if src_root then
          return "simple", src_root
        end

        -- Fallback to current file's directory
        return "simple", vim.fn.expand("%:p:h")
      end

      -- Detect main class from current Java file
      local function detect_java_main_class()
        local filename = vim.fn.expand("%:t:r") -- Class name from filename
        local lines = vim.api.nvim_buf_get_lines(0, 0, 30, false)
        local package_name = nil

        for _, line in ipairs(lines) do
          local pkg = line:match("^%s*package%s+([%w%.]+)%s*;")
          if pkg then
            package_name = pkg
            break
          end
        end

        if package_name then
          return package_name .. "." .. filename
        else
          return filename
        end
      end

      -- Check if current Java file has main method
      local function has_main_method()
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        for _, line in ipairs(lines) do
          if line:match("public%s+static%s+void%s+main") then
            return true
          end
        end
        return false
      end

      -- Detect C++ project type
      local function detect_cpp_project()
        local cmake_root = find_project_root({ "CMakeLists.txt" })
        if cmake_root then
          return "cmake", cmake_root
        end
        return "simple", vim.fn.expand("%:p:h")
      end

      -- ========================================
      -- C++ TASKS
      -- ========================================

      -- Simple C++ compile
      overseer.register_template({
        name = "cpp compile",
        builder = function()
          local file = vim.fn.expand("%:p")
          local output = vim.fn.expand("%:p:r")
          return {
            cmd = { "g++" },
            args = { "-std=c++17", "-Wall", file, "-o", output },
            components = {
              { "on_output_quickfix", open_on_exit = "failure" },
              "on_complete_notify",
              "default",
            },
          }
        end,
        condition = { filetype = { "cpp", "c" } },
      })

      -- C++ compile with debug symbols
      overseer.register_template({
        name = "cpp compile debug",
        builder = function()
          local file = vim.fn.expand("%:p")
          local output = vim.fn.expand("%:p:r")
          return {
            cmd = { "g++" },
            args = { "-g", "-std=c++17", "-Wall", file, "-o", output },
            components = {
              { "on_output_quickfix", open_on_exit = "failure" },
              "on_complete_notify",
              "default",
            },
          }
        end,
        condition = { filetype = { "cpp", "c" } },
      })

      -- C++ run executable
      overseer.register_template({
        name = "cpp run",
        builder = function()
          local output = vim.fn.expand("%:p:r")
          if vim.fn.filereadable(output) ~= 1 then
            vim.notify("Executable not found. Compile first with <leader>cc", vim.log.levels.WARN)
            -- Return a no-op task instead of nil to avoid error
            return {
              cmd = { "echo" },
              args = { "No executable found. Compile first." },
              components = { "default" },
            }
          end
          return {
            cmd = { output },
            components = { "default" },
          }
        end,
        condition = { filetype = { "cpp", "c" } },
      })

      -- C++ compile and run
      overseer.register_template({
        name = "cpp build and run",
        builder = function()
          local file = vim.fn.expand("%:p")
          local output = vim.fn.expand("%:p:r")
          return {
            cmd = { "sh" },
            args = { "-c", string.format("g++ -std=c++17 -Wall '%s' -o '%s' && '%s'", file, output, output) },
            components = {
              { "on_output_quickfix", open_on_exit = "failure" },
              "on_complete_notify",
              "default",
            },
          }
        end,
        condition = { filetype = { "cpp", "c" } },
      })

      -- C++ compile and run in terminal split (for interactive programs)
      overseer.register_template({
        name = "cpp run interactive",
        builder = function()
          local file = vim.fn.expand("%:p")
          local output = vim.fn.expand("%:p:r")
          return {
            cmd = { "sh" },
            args = { "-c", string.format("g++ -std=c++17 -Wall '%s' -o '%s' && '%s'", file, output, output) },
            components = { "default" },
          }
        end,
        condition = { filetype = { "cpp", "c" } },
      })

      -- CMake configure
      overseer.register_template({
        name = "cmake configure",
        builder = function()
          local _, root = detect_cpp_project()
          return {
            cmd = { "cmake" },
            args = { "-B", "build", "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
            cwd = root,
            components = {
              { "on_output_quickfix", open_on_exit = "failure" },
              "on_complete_notify",
              "default",
            },
          }
        end,
        condition = { filetype = { "cpp", "c", "cmake" } },
      })

      -- CMake build
      overseer.register_template({
        name = "cmake build",
        builder = function()
          local _, root = detect_cpp_project()
          return {
            cmd = { "cmake" },
            args = { "--build", "build" },
            cwd = root,
            components = {
              { "on_output_quickfix", open_on_exit = "failure" },
              "on_complete_notify",
              "default",
            },
          }
        end,
        condition = { filetype = { "cpp", "c", "cmake" } },
      })

      -- CMake run (finds executable in build dir)
      overseer.register_template({
        name = "cmake run",
        builder = function()
          local _, root = detect_cpp_project()
          local build_dir = root .. "/build"

          -- Find executable (exclude CMakeFiles directory which contains test executables)
          local handle = io.popen(string.format("find '%s' -maxdepth 1 -type f -perm +111 2>/dev/null | head -1", build_dir))
          local exe = handle:read("*a"):gsub("%s+", "")
          handle:close()

          if exe == "" then
            vim.notify("No executable found in build/. Run cmake build first.", vim.log.levels.WARN)
            return {
              cmd = { "echo" },
              args = { "No executable found. Run cmake build first." },
              components = { "default" },
            }
          end

          return {
            cmd = { exe },
            cwd = root,
            components = { "default" },
          }
        end,
        condition = { filetype = { "cpp", "c", "cmake" } },
      })

      -- ========================================
      -- PYTHON TASKS
      -- ========================================

      -- Detect Python interpreter (conda/venv/uv/.venv/system)
      local function detect_python_interpreter()
        -- Priority order: CONDA_PREFIX > VIRTUAL_ENV > uv > .venv > system python

        -- Check conda environment
        local conda_prefix = vim.env.CONDA_PREFIX
        if conda_prefix then
          local python_path = conda_prefix .. "/bin/python"
          if vim.fn.executable(python_path) == 1 then
            return python_path, "conda"
          end
        end

        -- Check virtualenv (venv or virtualenv)
        local virtual_env = vim.env.VIRTUAL_ENV
        if virtual_env then
          local python_path = virtual_env .. "/bin/python"
          if vim.fn.executable(python_path) == 1 then
            return python_path, "venv"
          end
        end

        -- Check for uv project (.venv in project root)
        local project_root = find_project_root({ "uv.lock", "pyproject.toml", ".venv" })
        if project_root then
          local uv_python = project_root .. "/.venv/bin/python"
          if vim.fn.executable(uv_python) == 1 then
            return uv_python, "uv"
          end
        end

        -- Check for .venv in current directory
        local current_dir = vim.fn.expand("%:p:h")
        local venv_python = current_dir .. "/.venv/bin/python"
        if vim.fn.executable(venv_python) == 1 then
          return venv_python, "venv"
        end

        -- Fallback to system python
        return "python3", "system"
      end

      -- Python run
      overseer.register_template({
        name = "python run",
        builder = function()
          local file = vim.fn.expand("%:p")
          local python_cmd, env_type = detect_python_interpreter()

          return {
            cmd = { python_cmd },
            args = { file },
            components = {
              { "on_output_quickfix", open_on_exit = "failure" },
              "on_complete_notify",
              "default",
            },
            metadata = {
              env_type = env_type,
            },
          }
        end,
        condition = { filetype = "python" },
      })

      -- Python run interactive (for input() programs)
      overseer.register_template({
        name = "python run interactive",
        builder = function()
          local file = vim.fn.expand("%:p")
          local python_cmd, env_type = detect_python_interpreter()

          return {
            cmd = { python_cmd },
            args = { file },
            components = { "default" },
            metadata = {
              env_type = env_type,
            },
          }
        end,
        condition = { filetype = "python" },
      })

      -- Python run with arguments
      overseer.register_template({
        name = "python run with args",
        builder = function()
          local file = vim.fn.expand("%:p")
          local python_cmd, env_type = detect_python_interpreter()

          -- Prompt for arguments
          local args = vim.fn.input("Arguments: ")
          local arg_list = {}
          if args ~= "" then
            -- Split arguments by spaces (simple split, doesn't handle quoted strings)
            for arg in args:gmatch("%S+") do
              table.insert(arg_list, arg)
            end
          end

          local all_args = { file }
          for _, arg in ipairs(arg_list) do
            table.insert(all_args, arg)
          end

          return {
            cmd = { python_cmd },
            args = all_args,
            components = { "default" },
            metadata = {
              env_type = env_type,
            },
          }
        end,
        condition = { filetype = "python" },
      })

      -- ========================================
      -- JAVA TASKS
      -- ========================================

      -- Java build (auto-detects Maven/Gradle/Simple)
      overseer.register_template({
        name = "java build",
        builder = function()
          local project_type, root = detect_java_project()

          if project_type == "maven" then
            return {
              cmd = { "mvn" },
              args = { "compile" },
              cwd = root,
              components = {
                { "on_output_quickfix", open_on_exit = "failure" },
                "on_complete_notify",
                "default",
              },
            }
          elseif project_type == "gradle" then
            local gradlew = root .. "/gradlew"
            local cmd = vim.fn.filereadable(gradlew) == 1 and gradlew or "gradle"
            return {
              cmd = { cmd },
              args = { "build", "-x", "test" },
              cwd = root,
              components = {
                { "on_output_quickfix", open_on_exit = "failure" },
                "on_complete_notify",
                "default",
              },
            }
          else
            -- Simple project: compile all java files in src to bin
            return {
              cmd = { "sh" },
              args = { "-c", "mkdir -p bin && find src -name '*.java' -print0 | xargs -0 javac -d bin" },
              cwd = root,
              components = {
                { "on_output_quickfix", open_on_exit = "failure" },
                "on_complete_notify",
                "default",
              },
            }
          end
        end,
        condition = { filetype = "java" },
      })

      -- Java run (auto-detects project type and main class)
      overseer.register_template({
        name = "java run",
        builder = function()
          local project_type, root = detect_java_project()
          local main_class = detect_java_main_class()

          if project_type == "maven" then
            -- Try to run with exec:java, passing main class if current file has main
            if has_main_method() then
              return {
                cmd = { "mvn" },
                args = { "exec:java", "-Dexec.mainClass=" .. main_class },
                cwd = root,
                components = { "default" },
              }
            else
              return {
                cmd = { "mvn" },
                args = { "exec:java" },
                cwd = root,
                components = { "default" },
              }
            end
          elseif project_type == "gradle" then
            -- Build with gradle first, then run with java directly (for stdin support)
            local gradlew = root .. "/gradlew"
            local gradle_cmd = vim.fn.filereadable(gradlew) == 1 and gradlew or "gradle"
            -- Build and find classes directory dynamically, then run with java
            return {
              cmd = { "sh" },
              args = { "-c", string.format(
                "%s build -x test -q && CLASSPATH=$(find '%s' -path '*/build/classes/java/main' -type d | head -1) && java -cp \"$CLASSPATH\" %s",
                gradle_cmd, root, main_class
              ) },
              cwd = root,
              components = { "default" },
            }
          else
            -- Simple project: compile and run
            -- First compile, then run the detected main class
            return {
              cmd = { "sh" },
              args = { "-c", string.format("mkdir -p bin && find src -name '*.java' -print0 | xargs -0 javac -d bin && java -cp bin %s", main_class) },
              cwd = root,
              components = { "default" },
            }
          end
        end,
        condition = { filetype = "java" },
      })

      -- Java test
      overseer.register_template({
        name = "java test",
        builder = function()
          local project_type, root = detect_java_project()

          if project_type == "maven" then
            return {
              cmd = { "mvn" },
              args = { "test" },
              cwd = root,
              components = {
                { "on_output_quickfix", open_on_exit = "failure" },
                "on_complete_notify",
                "default",
              },
            }
          elseif project_type == "gradle" then
            local gradlew = root .. "/gradlew"
            local cmd = vim.fn.filereadable(gradlew) == 1 and gradlew or "gradle"
            return {
              cmd = { cmd },
              args = { "test" },
              cwd = root,
              components = {
                { "on_output_quickfix", open_on_exit = "failure" },
                "on_complete_notify",
                "default",
              },
            }
          else
            vim.notify("Testing requires Maven or Gradle project", vim.log.levels.WARN)
            return {
              cmd = { "echo" },
              args = { "Testing requires Maven or Gradle project" },
              components = { "default" },
            }
          end
        end,
        condition = { filetype = "java" },
      })

      -- Java clean build
      overseer.register_template({
        name = "java clean",
        builder = function()
          local project_type, root = detect_java_project()

          if project_type == "maven" then
            return {
              cmd = { "mvn" },
              args = { "clean", "compile" },
              cwd = root,
              components = {
                { "on_output_quickfix", open_on_exit = "failure" },
                "on_complete_notify",
                "default",
              },
            }
          elseif project_type == "gradle" then
            local gradlew = root .. "/gradlew"
            local cmd = vim.fn.filereadable(gradlew) == 1 and gradlew or "gradle"
            return {
              cmd = { cmd },
              args = { "clean", "build", "-x", "test" },
              cwd = root,
              components = {
                { "on_output_quickfix", open_on_exit = "failure" },
                "on_complete_notify",
                "default",
              },
            }
          else
            -- Simple project
            return {
              cmd = { "sh" },
              args = { "-c", "rm -rf bin && mkdir -p bin && find src -name '*.java' -print0 | xargs -0 javac -d bin" },
              cwd = root,
              components = {
                { "on_output_quickfix", open_on_exit = "failure" },
                "on_complete_notify",
                "default",
              },
            }
          end
        end,
        condition = { filetype = "java" },
      })

      -- Java package (Maven only)
      overseer.register_template({
        name = "java package",
        builder = function()
          local project_type, root = detect_java_project()

          if project_type == "maven" then
            return {
              cmd = { "mvn" },
              args = { "package" },
              cwd = root,
              components = {
                { "on_output_quickfix", open_on_exit = "failure" },
                "on_complete_notify",
                "default",
              },
            }
          elseif project_type == "gradle" then
            local gradlew = root .. "/gradlew"
            local cmd = vim.fn.filereadable(gradlew) == 1 and gradlew or "gradle"
            return {
              cmd = { cmd },
              args = { "jar" },
              cwd = root,
              components = {
                { "on_output_quickfix", open_on_exit = "failure" },
                "on_complete_notify",
                "default",
              },
            }
          else
            vim.notify("Package requires Maven or Gradle project", vim.log.levels.WARN)
            return {
              cmd = { "echo" },
              args = { "Package requires Maven or Gradle project" },
              components = { "default" },
            }
          end
        end,
        condition = { filetype = "java" },
      })

      -- Java compile current file only (syntax check)
      overseer.register_template({
        name = "java compile file",
        builder = function()
          local file = vim.fn.expand("%:p")
          local file_dir = vim.fn.expand("%:p:h")
          local project_type, root = detect_java_project()

          -- Use Maven/Gradle compile for managed projects to handle modules properly
          if project_type == "maven" then
            return {
              cmd = { "mvn" },
              args = { "compile" },
              cwd = root,
              components = {
                { "on_output_quickfix", open_on_exit = "failure" },
                "on_complete_notify",
                "default",
              },
            }
          elseif project_type == "gradle" then
            local gradlew = root .. "/gradlew"
            local cmd = vim.fn.filereadable(gradlew) == 1 and gradlew or "gradle"
            return {
              cmd = { cmd },
              args = { "compileJava" },
              cwd = root,
              components = {
                { "on_output_quickfix", open_on_exit = "failure" },
                "on_complete_notify",
                "default",
              },
            }
          else
            -- Simple project: compile current file with classpath
            return {
              cmd = { "sh" },
              args = { "-c", string.format("javac -d bin -cp bin -sourcepath src '%s' 2>&1 || javac '%s'", file, file) },
              cwd = root,
              components = {
                { "on_output_quickfix", open_on_exit = "failure" },
                "on_complete_notify",
                "default",
              },
            }
          end
        end,
        condition = { filetype = "java" },
      })

      -- ========================================
      -- KEYMAPS (defined after templates)
      -- ========================================

      -- Helper to safely run a template
      local function run_task(name)
        return function()
          overseer.run_template({ name = name }, function(task)
            if task then
              overseer.open({ enter = false })
            end
          end)
        end
      end

      -- Smart C++ functions - auto-detect CMake vs simple
      local function smart_cpp_compile()
        local project_type, _ = detect_cpp_project()
        if project_type == "cmake" then
          run_task("cmake build")()
        else
          run_task("cpp compile")()
        end
      end

      local function smart_cpp_compile_debug()
        local project_type, _ = detect_cpp_project()
        if project_type == "cmake" then
          run_task("cmake build")()
        else
          run_task("cpp compile debug")()
        end
      end

      local function smart_cpp_run()
        local project_type, _ = detect_cpp_project()
        if project_type == "cmake" then
          run_task("cmake run")()
        else
          run_task("cpp run")()
        end
      end

      local function smart_cpp_build_and_run()
        local project_type, _ = detect_cpp_project()
        if project_type == "cmake" then
          run_task("cmake build")()
          vim.defer_fn(function()
            run_task("cmake run")()
          end, 1000)
        else
          run_task("cpp build and run")()
        end
      end

      local function smart_cpp_run_interactive()
        local project_type, _ = detect_cpp_project()
        if project_type == "cmake" then
          run_task("cmake run")()
        else
          run_task("cpp run interactive")()
        end
      end

      -- C++ keymaps
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "cpp", "c" },
        callback = function()
          local opts = { buffer = true, silent = true }
          -- Smart compile/run (works for both simple and CMake)
          vim.keymap.set("n", "<leader>cc", smart_cpp_compile, vim.tbl_extend("force", opts, { desc = "C++: Compile" }))
          vim.keymap.set("n", "<leader>cC", smart_cpp_compile_debug, vim.tbl_extend("force", opts, { desc = "C++: Compile Debug" }))
          vim.keymap.set("n", "<leader>cx", smart_cpp_run, vim.tbl_extend("force", opts, { desc = "C++: Run" }))
          vim.keymap.set("n", "<leader>cR", smart_cpp_build_and_run, vim.tbl_extend("force", opts, { desc = "C++: Build & Run" }))
          vim.keymap.set("n", "<leader>cX", smart_cpp_run_interactive, vim.tbl_extend("force", opts, { desc = "C++: Run Interactive" }))
          -- CMake specific
          vim.keymap.set("n", "<leader>cg", run_task("cmake configure"), vim.tbl_extend("force", opts, { desc = "CMake: Configure" }))
          vim.keymap.set("n", "<leader>cb", run_task("cmake build"), vim.tbl_extend("force", opts, { desc = "CMake: Build" }))
          vim.keymap.set("n", "<leader>cr", run_task("cmake run"), vim.tbl_extend("force", opts, { desc = "CMake: Run" }))
        end,
      })

      -- CMake file keymaps
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "cmake" },
        callback = function()
          local opts = { buffer = true, silent = true }
          vim.keymap.set("n", "<leader>cg", run_task("cmake configure"), vim.tbl_extend("force", opts, { desc = "CMake Generate" }))
          vim.keymap.set("n", "<leader>cb", run_task("cmake build"), vim.tbl_extend("force", opts, { desc = "CMake Build" }))
          vim.keymap.set("n", "<leader>cr", run_task("cmake run"), vim.tbl_extend("force", opts, { desc = "CMake Run" }))
        end,
      })

      -- Java keymaps
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = function()
          local opts = { buffer = true, silent = true }
          vim.keymap.set("n", "<leader>jb", run_task("java build"), vim.tbl_extend("force", opts, { desc = "Java: Build" }))
          vim.keymap.set("n", "<leader>jr", run_task("java run"), vim.tbl_extend("force", opts, { desc = "Java: Run" }))
          vim.keymap.set("n", "<leader>jt", run_task("java test"), vim.tbl_extend("force", opts, { desc = "Java: Test" }))
          vim.keymap.set("n", "<leader>jc", run_task("java clean"), vim.tbl_extend("force", opts, { desc = "Java: Clean Build" }))
          vim.keymap.set("n", "<leader>jp", run_task("java package"), vim.tbl_extend("force", opts, { desc = "Java: Package" }))
          vim.keymap.set("n", "<leader>jk", run_task("java compile file"), vim.tbl_extend("force", opts, { desc = "Java: Compile File" }))
        end,
      })

      -- Python keymaps
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "python",
        callback = function()
          local opts = { buffer = true, silent = true }
          vim.keymap.set("n", "<leader>pr", run_task("python run"), vim.tbl_extend("force", opts, { desc = "Python: Run" }))
          vim.keymap.set("n", "<leader>pi", run_task("python run interactive"), vim.tbl_extend("force", opts, { desc = "Python: Run Interactive" }))
          vim.keymap.set("n", "<leader>pa", run_task("python run with args"), vim.tbl_extend("force", opts, { desc = "Python: Run with Args" }))
        end,
      })

      -- General overseer keymaps (global)
      vim.keymap.set("n", "<leader>oo", "<cmd>OverseerRun<cr>", { desc = "Overseer: Run Task" })
      vim.keymap.set("n", "<leader>ot", "<cmd>OverseerToggle<cr>", { desc = "Overseer: Toggle" })
      vim.keymap.set("n", "<leader>oi", "<cmd>OverseerInfo<cr>", { desc = "Overseer: Info" })
      vim.keymap.set("n", "<leader>ol", "<cmd>OverseerRestartLast<cr>", { desc = "Overseer: Restart Last" })

      -- Terminal mode keymaps - easy exit from terminal
      vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
      vim.keymap.set("t", "<C-q>", "<C-\\><C-n>:q<cr>", { desc = "Close terminal" })
    end,
  },
}
