# Keybindings Quick Reference

## Organized by Prefix

### 🐛 Debugging - `<leader>d*` (lowercase d)

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>db` | Toggle Breakpoint | Set/remove breakpoint |
| `<leader>dB` | Conditional Breakpoint | Breakpoint with condition |
| `<leader>dc` | Continue/Start | Start or continue debugging |
| `<leader>dS` | Start (Select Config) | Show configuration picker |
| `<leader>di` | Step Into | Step into function |
| `<leader>do` | Step Over | Step over line |
| `<leader>dO` | Step Out | Step out of function |
| `<leader>dt` | Terminate | Stop debugging |
| `<leader>dr` | Restart | Restart debugging |
| `<leader>du` | Toggle DAP UI | Show/hide debug UI |
| `<leader>de` | Eval Expression | Evaluate under cursor |
| **Python-only** | | |
| `<leader>dc` | Start Debug | Auto-select "file" config (no picker) |
| `<leader>dm` | Debug Test Method | Debug test under cursor |
| `<leader>dM` | Debug Test Class | Debug entire test class |
| `<leader>ds` | Debug Selection | Debug selected code (visual) |
| **C/C++-only** | | |
| `<leader>dc` | Start Debug | Auto-select "Launch file" (prompts for executable) |

### 🗄️ Database/SQL - `<leader>D*` (capital D)

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>Db` | Toggle Database UI | Open/close DBUI |
| `<leader>Df` | Find Database Buffer | Find DB buffer |
| `<leader>Dr` | Rename Database Buffer | Rename buffer |
| `<leader>Dl` | Last Query Info | Show last query |
| `<leader>Da` | Add Connection | Add DB connection |

### 🔧 C++ / CMake - `<leader>c*`

| Key | Action | Context |
|-----|--------|---------|
| **Simple C++ Files** | | |
| `<leader>cc` | Compile | Compile current file |
| `<leader>cC` | Compile (Debug) | Compile with -g flag |
| `<leader>cx` | Run | Run compiled executable |
| `<leader>cR` | Compile & Run | Compile then run immediately |
| `<leader>cX` | Run in Terminal Split | Compile & run in split |
| **CMake Projects** | | |
| `<leader>cg` | CMake Generate | Generate build files |
| `<leader>cb` | CMake Build | Build project |
| `<leader>cr` | CMake Run | Run executable |
| `<leader>cd` | CMake Debug | Debug with CMake |
| `<leader>ct` | CMake Select Build Type | Choose Debug/Release |
| `<leader>cs` | CMake Settings | Configure CMake |

### ☕ Java - `<leader>j*`

| Key | Action | Context |
|-----|--------|---------|
| `<leader>jb` | Build | Maven/Gradle/Simple |
| `<leader>jr` | Run | Maven/Gradle/Simple |
| `<leader>jt` | Test | Maven/Gradle |
| `<leader>jc` | Clean Build | Maven/Gradle/Simple |
| `<leader>jp` | Package | Maven only |
| `<leader>jR` | Run Current Class | Gradle only |
| `<leader>jk` | Compile Current File | All (javac) |
| `<leader>jn` | New Java Class | All |

### 🧪 Testing (Java) - `<leader>t*`

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>tc` | Test Class | Run all tests in class |
| `<leader>tm` | Test Method | Run test under cursor |
| `<leader>th` | Toggle Inlay Hints | Show/hide type hints |

### 📝 Code Actions (Java) - `<leader>c*`

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>co` | Organize Imports | Sort and remove unused |
| `<leader>cv` | Extract Variable | Extract to variable |
| `<leader>cC` | Extract Constant | Extract to constant |
| `<leader>cm` | Extract Method | Extract to method (visual) |

### 📓 Jupyter/Molten - `<leader>m*`

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>mi` | Molten Init | Initialize Python kernel |
| `<leader>me` | Molten Eval | Eval operator/visual |
| `<leader>ml` | Molten Eval Line | Eval current line |
| `<leader>mc` | Molten Eval Cell | Re-eval current cell |
| `<leader>mo` | Molten Show Output | Show cell output |
| `<leader>mh` | Molten Hide Output | Hide cell output |
| `<leader>mO` | Molten Enter Output | Enter output window |
| `<leader>md` | Molten Delete Cell | Delete cell + clear images |
| `<leader>mx` | Molten Interrupt | Interrupt kernel |
| `<leader>mr` | Molten Restart | Restart kernel |
| `]c` | Next Cell | Jump to next cell |
| `[c` | Previous Cell | Jump to prev cell |

### 📔 Jupyter Files - `<leader>n*` / `<leader>j*`

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>nb` | New Notebook | Create .ipynb file |
| `<leader>j%` | Insert Cell Marker | Add # %% marker |

### 🗃️ Quarto - `<leader>q*`

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>qp` | Quarto Preview | Preview document |
| `<leader>qr` | Quarto Run | Run cell |
| `<leader>qci` | Convert ipynb→qmd | Convert notebook |
| `<leader>qcq` | Convert qmd→ipynb | Convert to notebook |

## Mnemonic Guide

### Why these prefixes?

- **d** = **Debug** (lowercase) - Most common, easy to type
- **D** = **Database** (capital) - Related to 'd' but distinct
- **j** = **Java** - Language-specific
- **t** = **Test** - Testing commands
- **c** = **Code** actions - Refactoring, formatting
- **m** = **Molten** - Jupyter execution
- **n** = **New** - Creating new files
- **q** = **Quarto** - Document format
- **sq** = **SQL** query (alternative prefix if needed)

## Conflict Resolution

Previously `<leader>db` was used by both:
- ❌ Database UI toggle
- ❌ Debug breakpoint

**Solution:** Database commands now use capital `D`:
- ✅ `<leader>db` = Debug Breakpoint
- ✅ `<leader>Db` = Database UI toggle

## Common Workflows

### Python Debugging Session
```
1. <leader>db     - Set breakpoint
2. <leader>dc     - Start debugging
3. <leader>di/do  - Step through
4. <leader>de     - Inspect variables
5. <leader>dt     - Stop
```

### Java Development
```
1. <leader>jb     - Build project
2. <leader>jr     - Run main class
3. <leader>tm     - Test method
4. <leader>co     - Organize imports
```

### Jupyter Notebook
```
1. <leader>nb     - Create notebook
2. <leader>mi     - Init kernel
3. <leader>mc     - Run cell
4. <leader>md     - Delete output
```

### Database Query
```
1. <leader>Db     - Open DB UI
2. <leader>Da     - Add connection
3. <leader>Dl     - View last query
```

## Tips

1. **Which-key**: LazyVim shows available keys when you type `<leader>`
2. **Search keybindings**: `:Telescope keymaps`
3. **Leader key**: Usually `Space` or `\` (check with `:let mapleader`)
4. **Case matters**: `<leader>d` ≠ `<leader>D`
