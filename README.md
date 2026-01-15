# Neovim Configuration

Personal Neovim configuration based on [LazyVim](https://github.com/LazyVim/LazyVim).

## Features

- **Multi-language support**: Java, Python, C++, SQL/PostgreSQL, LaTeX, Markdown
- **Database tools**: vim-dadbod-ui for database management
- **Jupyter integration**: Notebook support via Molten
- **Task runner**: Overseer.nvim with language-specific build/run templates
- **VSCode compatibility**: Works seamlessly with VSCode Neovim extension
- **Tmux integration**: vim-tmux-navigator for pane navigation

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

| Key | Description |
|-----|-------------|
| `<leader>db` | Toggle Database UI |
| `<leader>jn` | Create new Java class |
| `<leader>or` | Run Overseer task |
| `<leader>ot` | Toggle Overseer window |

## Requirements

- Neovim >= 0.9.0
- [Nerd Font](https://www.nerdfonts.com/) (optional, for icons)
- Language-specific tools installed via Mason

## Installation

```bash
# Backup existing config
mv ~/.config/nvim ~/.config/nvim.bak

# Clone this config
git clone https://github.com/YOUR_USERNAME/nvim.git ~/.config/nvim

# Open Neovim (plugins install automatically)
nvim
```

## License

MIT
