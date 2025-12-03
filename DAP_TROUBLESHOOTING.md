# DAP Troubleshooting Guide

## Current Issues & Fixes

### Issue 1: Config Picker Still Shows

**Problem:** When pressing `<leader>dc`, you still see the configuration picker.

**Solution:**
1. Restart nvim completely (the config override needs to load)
2. Or reload the config:
   ```vim
   :lua package.loaded['plugins.editor.dap'] = nil
   :Lazy reload nvim-dap
   ```

### Issue 2: Test Method Debug Error

**Problem:** `<leader>dm` shows traceback error about debugpy.

**Current debugpy setup:**
- Path: `~/.local/share/nvim/mason/packages/debugpy/debugpy-adapter`
- Python: 3.14.0
- Status: ✅ Installed

**Fix Applied:**
- Changed setup to use `debugpy-adapter` executable instead of python path
- This is the recommended approach for newer debugpy versions

## Testing Steps

### 1. Verify debugpy Installation

```bash
# Check Mason installation
ls ~/.local/share/nvim/mason/packages/debugpy/

# Should show:
# - debugpy-adapter
# - venv/
```

### 2. Test Basic Debugging

Open the test file:
```bash
nvim ~/Downloads/winter_25/10714/hw0/test_debug.py
```

Steps:
1. Move cursor to line 7 (`result = a + b`)
2. Press `<leader>db` to set breakpoint (red dot should appear)
3. Press `<leader>dc` to start debugging
4. Should start immediately WITHOUT showing config picker
5. DAP UI should open on left/bottom
6. Current line should highlight with arrow (→)

### 3. Test Config Picker

If you want to see ALL configs:
- Press `<leader>dS` (capital S) - Shows config selector

### 4. Check DAP Status

In nvim:
```vim
:lua vim.print(require('dap').configurations.python)
```

Should show 4 configurations:
1. Python: Current File
2. Python: Current File with Arguments
3. Python: Attach
4. Python: Current File (pytest)

### 5. Debug Test Methods

For testing `<leader>dm` (debug test method):

Create a test file:
```python
# test_example.py
def test_addition():
    assert 1 + 1 == 2

def test_multiplication():
    result = 3 * 4
    assert result == 12
```

Then:
1. Put cursor on/in `test_addition`
2. Press `<leader>dm`
3. Should debug just that test

## Common Errors

### Error: "No configuration found"

**Cause:** dap-python not loaded properly

**Fix:**
```vim
:lua require('dap-python').setup(vim.fn.stdpath('data') .. '/mason/packages/debugpy/debugpy-adapter')
:lua vim.print(require('dap').configurations.python)
```

### Error: "Debugpy not found"

**Cause:** debugpy not installed

**Fix:**
```vim
:MasonInstall debugpy
```

### Error: Config picker still shows

**Cause:** Config not reloaded

**Fix:**
```vim
" Completely restart nvim
" OR
:qa
nvim test_debug.py
```

## Updated Keybindings

| Key | Action | Notes |
|-----|--------|-------|
| `<leader>dc` | Start/Continue | Auto-selects "file" config (no picker) |
| `<leader>dS` | Select Config | Shows config picker explicitly |
| `<leader>dm` | Debug Test Method | Uses pytest/unittest |
| `<leader>dM` | Debug Test Class | All tests in class |

## Verification Checklist

- [ ] debugpy installed via Mason
- [ ] Restarted nvim
- [ ] Can set breakpoint with `<leader>db`
- [ ] `<leader>dc` starts immediately (no picker)
- [ ] DAP UI opens automatically
- [ ] Can step through code with `<leader>di`/`<leader>do`
- [ ] Variables show in Scopes panel
- [ ] Virtual text shows variable values

## If Nothing Works

1. Check health:
```vim
:checkhealth dap
```

2. Check Python path:
```vim
:lua vim.print(vim.fn.exepath('python3'))
```

3. Reinstall debugpy:
```vim
:MasonUninstall debugpy
:MasonInstall debugpy
```

4. Check dap-python setup:
```vim
:lua vim.print(require('dap-python'))
```

5. Enable debug logging:
```vim
:lua require('dap').set_log_level('TRACE')
:lua vim.cmd('e ' .. vim.fn.stdpath('cache') .. '/dap.log')
```

## Working Configuration

Your current setup:
- debugpy: `~/.local/share/nvim/mason/packages/debugpy/debugpy-adapter`
- Python: 3.14.0
- DAP UI: Auto-opens on debug start
- Virtual text: Enabled
- Auto-config: `<leader>dc` → first config (file)
- Manual config: `<leader>dS` → show picker

## Quick Test Command

```bash
# In terminal
cd ~/Downloads/winter_25/10714/hw0
nvim test_debug.py

# In nvim
# Line 7: <leader>db  (set breakpoint)
# Line 7: <leader>dc  (start debug - should NOT show picker)
# Line 7: <leader>di  (step into)
# Line 7: <leader>dt  (terminate)
```

## Expected Behavior

### Before Fix
```
<leader>dc → Shows picker with 4 options
You select "file"
Debugging starts
```

### After Fix
```
<leader>dc → Debugging starts immediately
No picker shown
Uses "Python: Current File" automatically
```

### If You Need Picker
```
<leader>dS → Shows picker with 4 options
You select the one you want
Debugging starts
```
