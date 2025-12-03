# DAP (Debug Adapter Protocol) Setup Guide

## Installation Status

✅ **Installed Plugins:**
- `nvim-dap` - Core DAP client
- `nvim-dap-ui` - Visual debugging interface
- `nvim-dap-virtual-text` - Shows variable values inline
- `nvim-dap-python` - Python debugging adapter
- `nvim-nio` - Async I/O library (required by dap-ui)

## Setup Instructions

### 1. Install debugpy (Required for Python debugging)

Open nvim and run:
```
:MasonInstall debugpy
```

Or install it directly:
```bash
pip install debugpy
```

### 2. Verify Installation

Open nvim and run:
```
:checkhealth dap
```

## Keybindings

### Basic Debugging Controls

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>db` | Toggle Breakpoint | Set/remove breakpoint on current line |
| `<leader>dB` | Conditional Breakpoint | Set breakpoint with condition |
| `<leader>dc` | Continue/Start | Start debugging or continue to next breakpoint |
| `<leader>di` | Step Into | Step into function call |
| `<leader>do` | Step Over | Step over function call |
| `<leader>dO` | Step Out | Step out of current function |
| `<leader>dt` | Terminate | Stop debugging session |
| `<leader>dr` | Restart | Restart debugging session |

### DAP UI Controls

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>du` | Toggle DAP UI | Show/hide debugging interface |
| `<leader>de` | Eval Expression | Evaluate expression under cursor (normal/visual mode) |

### Python-Specific (only in Python files)

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>dc` | Start/Continue Debug | **Auto-selects "file" config** (no picker) |
| `<leader>dC` | Start Debug (Choose) | **Shows config picker** (file/module/attach/etc) |
| `<leader>dm` | Debug Test Method | Debug the test method under cursor |
| `<leader>dM` | Debug Test Class | Debug entire test class |
| `<leader>ds` | Debug Selection | Debug selected code (visual mode) |

**Note:** In Python files, `<leader>dc` automatically uses the "Python: Current File" configuration to avoid the picker. Use `<leader>dC` (capital C) if you want to choose a different configuration (like module, attach to process, etc).

## DAP UI Layout

When debugging starts, DAP UI automatically opens with:

**Left Panel (40 columns):**
- **Scopes** - Local and global variables
- **Breakpoints** - All breakpoints in your project
- **Stacks** - Call stack/frames
- **Watches** - Custom watch expressions

**Bottom Panel (10 rows):**
- **REPL** - Interactive debugger console
- **Console** - Debug output

### DAP UI Mappings (inside DAP UI windows)

| Key | Action |
|-----|--------|
| `<CR>` or double-click | Expand/collapse |
| `o` | Open file/variable |
| `d` | Remove breakpoint/watch |
| `e` | Edit value |
| `r` | Open REPL |
| `t` | Toggle |
| `q` or `<Esc>` | Close floating window |

## Basic Debugging Workflow

### 1. Set Breakpoints
```lua
-- Move cursor to line where you want to pause execution
-- Press <leader>db to toggle breakpoint
-- A red dot (●) will appear in the sign column
```

### 2. Start Debugging
```lua
-- Press <leader>dc to start debugging
-- DAP UI will automatically open
-- Your program will run until it hits a breakpoint
```

### 3. Navigate Through Code
```lua
-- <leader>di - Step into functions
-- <leader>do - Step over (execute current line)
-- <leader>dO - Step out of current function
-- <leader>dc - Continue to next breakpoint
```

### 4. Inspect Variables
```lua
-- Hover over variables to see values
-- Check the Scopes panel in DAP UI for all variables
-- Use <leader>de to evaluate custom expressions
```

### 5. Stop Debugging
```lua
-- <leader>dt - Terminate session
-- DAP UI will automatically close
```

## Python Debugging Examples

### Debug a Python Script

1. Open your Python file
2. Set breakpoints with `<leader>db`
3. Start debugging with `<leader>dc`
4. Select configuration: "Python: Current File"

### Debug a Test Method

1. Open your test file (pytest, unittest, etc.)
2. Put cursor on or inside a test function
3. Press `<leader>dm` to debug just that test
4. Debugger will stop at first breakpoint in the test

### Debug Selected Code

1. Select code in visual mode
2. Press `<leader>ds`
3. Selected code will execute in debug mode

## Virtual Environment Detection

`nvim-dap-python` automatically detects your virtual environment:
- Checks `VIRTUAL_ENV` environment variable
- Checks `CONDA_PREFIX` for conda environments
- Looks for `venv/`, `.venv/`, `env/`, `.env/` folders

## Breakpoint Icons

| Icon | Meaning |
|------|---------|
| ● (red) | Active breakpoint |
| ◆ | Conditional breakpoint |
| ○ | Rejected/invalid breakpoint |
| → (green) | Current execution line |
| ◎ | Log point |

## Troubleshooting

### debugpy not found
```bash
# Install via Mason
:MasonInstall debugpy

# Or via pip
pip install debugpy
```

### DAP UI doesn't open
```lua
-- Manually toggle it
:lua require('dapui').toggle()
```

### Virtual text not showing
```lua
-- Check if it's enabled
:lua require('nvim-dap-virtual-text').toggle()
```

### Breakpoints not working
```lua
-- Check DAP status
:lua require('dap').status()

-- List all breakpoints
:lua vim.print(require('dap').breakpoints.get())
```

## Advanced Configuration

### Add Watch Expression
In DAP UI, navigate to the Watches section and press `a` to add a new watch.

### Conditional Breakpoint
Press `<leader>dB` and enter a Python expression (e.g., `x > 10`).

### REPL Commands
When in REPL (bottom panel):
- Type Python expressions to evaluate
- Access variables in current scope
- Execute statements

## Integration with Your Setup

This DAP configuration is compatible with:
- ✅ Your existing Java debugging (via nvim-jdtls)
- ✅ LazyVim plugin structure
- ✅ Mason package manager
- ✅ Conda/virtualenv environments
- ✅ Your current keybinding scheme

### Keybinding Organization
- `<leader>d*` - **Debugging/DAP** (e.g., `<leader>db` = breakpoint, `<leader>dc` = continue)
- `<leader>D*` - **Database/SQL** (e.g., `<leader>Db` = database UI, `<leader>Df` = find buffer)
- `<leader>j*` - **Java** (e.g., `<leader>jb` = build, `<leader>jr` = run)
- `<leader>t*` - **Testing** (e.g., `<leader>tc` = test class, `<leader>tm` = test method)

## File Location

Configuration file: `~/.config/nvim/lua/plugins/editor/dap.lua`
