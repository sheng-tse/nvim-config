# C++ Development Setup

## Overview

Your nvim is now configured for C++ development with:
- **LSP**: clangd for code intelligence
- **Debugging**: codelldb via nvim-dap
- **Build System**: CMake integration (optional)
- **Formatting**: clang-format via conform.nvim
- **Auto-config**: No picker for debugging (auto-selects "Launch file")

## Installation

### 1. Install Tools via Mason

```vim
:MasonInstall clangd codelldb clang-format
```

### 2. System Requirements

**macOS (you):**
```bash
# Install Xcode Command Line Tools (if not already installed)
xcode-select --install

# Or install full Xcode from App Store
```

**Optional - CMake:**
```bash
brew install cmake
```

## Features

### LSP (clangd)

**Capabilities:**
- Code completion
- Go to definition/declaration
- Find references
- Rename symbols
- Code actions (refactoring)
- Diagnostics (errors/warnings)
- Include management (IWYU style)

**Configuration:**
- Background indexing for fast lookups
- Clang-tidy integration for linting
- Detailed completion with placeholders
- Automatic header insertion

### Debugging (codelldb)

**Supported Configurations:**

1. **Launch file** (default, auto-selected)
   - Prompts for executable path
   - Runs your compiled program in debug mode

2. **Attach to process**
   - Attach debugger to running process
   - Shows process picker

**Supported Languages:**
- C
- C++
- Rust (bonus!)

### CMake Integration

**Commands:**

| Key | Command | Description |
|-----|---------|-------------|
| `<leader>cg` | CMakeGenerate | Generate build files |
| `<leader>cb` | CMakeBuild | Build project |
| `<leader>cr` | CMakeRun | Run executable |
| `<leader>cd` | CMakeDebug | Debug with CMake |
| `<leader>ct` | CMakeSelectBuildType | Choose Debug/Release |
| `<leader>cs` | CMakeSettings | Configure CMake |

**Features:**
- Automatic compile_commands.json generation
- Build type selection (Debug/Release/RelWithDebInfo)
- Integrated terminal for build output
- Direct debugging integration

## Debugging Workflow

### Basic C++ Program

**1. Create test file:**

```cpp
// test.cpp
#include <iostream>

int add(int a, int b) {
    int result = a + b;  // Set breakpoint here
    return result;
}

int main() {
    std::cout << "Starting debug test..." << std::endl;

    int x = 5;
    int y = 10;
    int total = add(x, y);

    std::cout << "Result: " << total << std::endl;
    return 0;
}
```

**2. Compile:**

```bash
# Simple compilation
g++ -g test.cpp -o test

# Or with clang
clang++ -g test.cpp -o test
```

**3. Debug:**

```vim
" Open the file
:e test.cpp

" Set breakpoint on line 5 (inside add function)
:5
<leader>db

" Start debugging
<leader>dc

" It will prompt: "Path to executable: /path/to/test"
" Enter the path to your compiled executable
```

**4. Navigate:**
- `<leader>di` - Step into functions
- `<leader>do` - Step over lines
- `<leader>dO` - Step out of function
- `<leader>dc` - Continue to next breakpoint

### CMake Project

**Project structure:**
```
my_project/
├── CMakeLists.txt
├── src/
│   └── main.cpp
└── include/
    └── mylib.h
```

**CMakeLists.txt example:**
```cmake
cmake_minimum_required(VERSION 3.10)
project(MyProject)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)  # Important for clangd

add_executable(myapp src/main.cpp)
```

**Workflow:**

```vim
" 1. Generate build files
<leader>cg

" 2. Build project
<leader>cb

" 3. Run
<leader>cr

" 4. Debug (automatically uses built executable)
<leader>cd
```

## Comparison: C++ vs Python Setup

### Similarities ✅

| Feature | Python | C++ |
|---------|--------|-----|
| **Auto-config** | ✅ No picker | ✅ No picker |
| **DAP UI** | ✅ Auto-open | ✅ Auto-open |
| **Virtual Text** | ✅ Inline vars | ✅ Inline vars |
| **LSP** | basedpyright | clangd |
| **Formatter** | ruff | clang-format |
| **Debugging** | debugpy | codelldb |

### Differences

| Aspect | Python | C++ |
|--------|--------|-----|
| **Compile Step** | None (interpreted) | Required |
| **Build System** | - | CMake integration |
| **Test Debugging** | `<leader>dm` (pytest) | Build test executable |
| **Executable Input** | Auto-detects | Prompts for path |

## Configuration Details

### clangd Setup

**File:** `lua/plugins/lang/cpp.lua:6-29`

**Key settings:**
```lua
cmd = {
  "clangd",
  "--background-index",      -- Index code in background
  "--clang-tidy",            -- Enable linting
  "--header-insertion=iwyu", -- Smart #include management
  "--completion-style=detailed",
  "--function-arg-placeholders",
}
```

### codelldb Setup

**File:** `lua/plugins/lang/cpp.lua:37-84`

**Adapter:**
```lua
dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = {
    command = "~/.local/share/nvim/mason/bin/codelldb",
    args = { "--port", "${port}" },
  },
}
```

### Formatting

**File:** `lua/plugins/lang/cpp.lua:130-142`

**Style:** Google style with customizations
- Indent width: 4 spaces
- Column limit: 100 characters

**Format command:**
```vim
<leader>cf  " Format current buffer
```

## Keybindings Summary

### Debugging

| Key | Action |
|-----|--------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Start/Continue (auto-selects "Launch file") |
| `<leader>dS` | Show config picker (choose manually) |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>dO` | Step out |
| `<leader>dt` | Terminate |
| `<leader>du` | Toggle DAP UI |

### CMake (C++ files only)

| Key | Action |
|-----|--------|
| `<leader>cg` | Generate |
| `<leader>cb` | Build |
| `<leader>cr` | Run |
| `<leader>cd` | Debug |
| `<leader>ct` | Select build type |

### LSP (automatic)

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | Find references |
| `K` | Hover documentation |
| `<leader>ca` | Code actions |
| `<leader>cr` | Rename |

## Troubleshooting

### clangd not finding headers

**Create `.clangd` config in project root:**

```yaml
CompileFlags:
  Add:
    - "-I/usr/local/include"
    - "-I/path/to/your/includes"
```

**Or use CMake:**
```cmake
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
```

Then symlink:
```bash
ln -s build/compile_commands.json .
```

### codelldb not working

**Check installation:**
```vim
:lua vim.print(vim.fn.exepath("codelldb"))
" Should show path to codelldb
```

**Reinstall:**
```vim
:MasonUninstall codelldb
:MasonInstall codelldb
```

### Debugging stops immediately

**Check executable has debug symbols:**
```bash
# Compile with -g flag
g++ -g -o myapp main.cpp

# Verify debug symbols exist
file myapp
# Should show: "not stripped"
```

### CMake not found

**Install CMake:**
```bash
brew install cmake
```

Or use Mason:
```vim
:MasonInstall cmake
```

## Example Projects

### Simple C++ Project

```bash
mkdir test_cpp && cd test_cpp
```

**main.cpp:**
```cpp
#include <iostream>
#include <vector>

void print_vector(const std::vector<int>& vec) {
    for (int val : vec) {
        std::cout << val << " ";  // Breakpoint here
    }
    std::cout << std::endl;
}

int main() {
    std::vector<int> numbers = {1, 2, 3, 4, 5};
    print_vector(numbers);
    return 0;
}
```

**Compile & Debug:**
```bash
g++ -g -std=c++17 main.cpp -o main
nvim main.cpp

# In nvim:
# Line 6: <leader>db
# <leader>dc
# Enter: ./main
```

### CMake Project

**CMakeLists.txt:**
```cmake
cmake_minimum_required(VERSION 3.10)
project(TestApp VERSION 1.0)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

add_executable(app main.cpp)
```

**In nvim:**
```vim
<leader>cg  " Generate
<leader>cb  " Build
<leader>cd  " Debug (auto-selects build/app)
```

## Status

Your C++ setup now matches your Python setup quality:

✅ **LSP configured** (clangd)
✅ **Debugger configured** (codelldb)
✅ **Auto-config selection** (no picker)
✅ **DAP UI integration** (auto-open/close)
✅ **Virtual text** (inline variables)
✅ **Formatting** (clang-format)
✅ **Build system** (CMake optional)

## Files Created/Modified

- `lua/plugins/lang/cpp.lua` - Complete C++ configuration
- `lua/plugins/editor/dap.lua` - Updated to support C/C++ auto-config
- `CPP_SETUP.md` - This guide

**Ready to debug C++ code!**
