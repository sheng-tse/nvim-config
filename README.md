# Neovim Configuration

Personal Neovim configuration based on [LazyVim](https://github.com/LazyVim/LazyVim).

## Features

- **Multi-language support**: Java, Python, C++, SQL/PostgreSQL, LaTeX, Markdown
- **Database tools**: vim-dadbod-ui for database management
- **Jupyter integration**: Notebook support via Molten with inline image display
- **Task runner**: Overseer.nvim with auto-detection for Maven/Gradle/CMake projects
- **VSCode compatibility**: Works seamlessly with VSCode Neovim extension
- **Tmux integration**: vim-tmux-navigator for pane navigation
- **Cross-platform**: Works on macOS (ARM/Intel) and Linux

## Requirements

### Core Requirements

- **Neovim >= 0.9.0**
- **Git**
- **Node.js** (for markdown-preview.nvim)
- [Nerd Font](https://www.nerdfonts.com/) (optional, for icons)

### Language-Specific Dependencies

Dependencies are installed automatically via Mason where possible. External tools listed below must be installed manually.

#### Java

- **JDK 17+** (required)
- Maven or Gradle (for project builds)
- LSP: `jdtls` (auto-installed via Mason)

```bash
# macOS
brew install openjdk@17 maven gradle

# Ubuntu/Debian
sudo apt install openjdk-17-jdk maven gradle
```

#### Python

- **Python 3.8+** (required)
- LSP: `basedpyright` (auto-installed via Mason)
- Debugger: `debugpy` (auto-installed via Mason)

```bash
# For Jupyter/Molten support
pip install pynvim jupytext

# Optional: for virtual environments
pip install virtualenv
# or use conda/uv
```

#### C/C++

- **Clang/LLVM** (required for clangd LSP)
- CMake (optional, for CMake projects)
- LSP: `clangd` (auto-installed via Mason)
- Debugger: `codelldb` (auto-installed via Mason)

```bash
# macOS
brew install llvm cmake

# Ubuntu/Debian
sudo apt install clangd cmake build-essential
```

#### LaTeX

- **TeX distribution** (required)
- **latexmk** (required for compilation)
- PDF viewer: Skim (macOS) / Zathura, Evince, or Okular (Linux)

```bash
# macOS
brew install --cask mactex-no-gui
brew install latexmk texcount

# Ubuntu/Debian
sudo apt install texlive-full latexmk texcount

# PDF viewer (Linux)
sudo apt install zathura zathura-pdf-poppler
```

#### SQL/PostgreSQL

- PostgreSQL client tools (optional, for vim-dadbod)
- LSP: `postgres-language-server` (auto-installed via Mason)
- Formatter: `pgformatter` (auto-installed via Mason)

```bash
# macOS
brew install postgresql

# Ubuntu/Debian
sudo apt install postgresql-client
```

#### Markdown

- Node.js (required for markdown-preview.nvim)

```bash
# macOS
brew install node

# Ubuntu/Debian
sudo apt install nodejs npm
```

#### Jupyter/Image Support (Optional)

For inline image display in Jupyter notebooks:

- **ImageMagick**
- **LuaRocks**
- **LuaJIT**
- Terminal with image support (Kitty, Ghostty, or iTerm2)

```bash
# macOS
brew install imagemagick luarocks luajit

# Ubuntu/Debian
sudo apt install imagemagick luarocks luajit-5.1-dev
```

## Installation

```bash
# Backup existing config
mv ~/.config/nvim ~/.config/nvim.bak

# Clone this config
git clone https://github.com/sheng-tselin/nvim.git ~/.config/nvim

# Open Neovim (plugins install automatically)
nvim
```

On first launch:
1. Lazy.nvim will automatically install all plugins
2. Mason will install configured LSP servers and tools
3. Treesitter will download parsers for configured languages

## Structure

```
lua/
├── config/           # Core configuration
│   ├── autocmds.lua  # Auto commands
│   ├── keymaps.lua   # Key mappings
│   ├── lazy.lua      # Plugin manager setup
│   └── options.lua   # Neovim options
└── plugins/          # Plugin configurations
    ├── editor/       # Editor enhancements (Telescope, DAP, Treesitter)
    ├── lang/         # Language-specific (database, jupyter, latex)
    ├── lsp/          # LSP configs (java, python, postgresql)
    └── ui/           # UI plugins (rainbow brackets)
```

## Key Bindings

### General

| Key | Description |
|-----|-------------|
| `<leader>oo` | Run Overseer task |
| `<leader>ot` | Toggle Overseer window |
| `<leader>ol` | Restart last task |

### Database

| Key | Description |
|-----|-------------|
| `<leader>Db` | Toggle Database UI |
| `<leader>Da` | Add Database Connection |

### Java

| Key | Description |
|-----|-------------|
| `<leader>jn` | Create new Java class |
| `<leader>jb` | Build project |
| `<leader>jr` | Run project |
| `<leader>jt` | Run tests |
| `<leader>jc` | Clean build |

### Python

| Key | Description |
|-----|-------------|
| `<leader>pr` | Run Python file |
| `<leader>pi` | Run interactive (with input) |
| `<leader>pa` | Run with arguments |

### C++

| Key | Description |
|-----|-------------|
| `<leader>cc` | Compile |
| `<leader>cx` | Run |
| `<leader>cR` | Build & Run |
| `<leader>cg` | CMake configure |
| `<leader>cb` | CMake build |

### Jupyter/Molten

| Key | Description |
|-----|-------------|
| `<leader>mi` | Initialize Molten kernel |
| `<leader>mc` | Evaluate cell |
| `<leader>ml` | Evaluate line |
| `<leader>md` | Delete cell output |

### LaTeX

| Key | Description |
|-----|-------------|
| `<leader>ll` | Compile LaTeX |
| `<leader>lv` | View PDF |
| `<leader>lt` | Toggle TOC |
| `<C-l>` | Fix spelling (insert mode) |

### Debugging

| Key | Description |
|-----|-------------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Continue/Start |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>du` | Toggle DAP UI |

### Markdown

| Key | Description |
|-----|-------------|
| `<leader>mp` | Preview markdown |
| `<leader>ms` | Stop preview |

## Troubleshooting

### LSP not starting

Run `:Mason` and ensure the required language servers are installed. For manual installation:

```vim
:MasonInstall jdtls basedpyright clangd postgres-language-server
```

### Java JDTLS issues

1. Ensure JDK 17+ is installed and `java` is in PATH
2. Check workspace: `:lua print(vim.fn.stdpath("data") .. "/jdtls-workspaces/")`
3. Clean workspace: `rm -rf ~/.local/share/nvim/jdtls-workspaces/`

### Python virtual environment not detected

The config auto-detects environments in this order:
1. `CONDA_PREFIX` (conda activate)
2. `VIRTUAL_ENV` (venv/virtualenv)
3. `.venv/` in project directory (uv/poetry)
4. System Python

### LaTeX viewer not opening

- **macOS**: Install Skim: `brew install --cask skim`
- **Linux**: Install Zathura: `sudo apt install zathura`

### Jupyter images not displaying

1. Use a terminal with image protocol support (Kitty, Ghostty, iTerm2)
2. Install ImageMagick and LuaRocks (see dependencies above)
3. Rebuild image.nvim: `:Lazy build image.nvim`

## License

MIT
