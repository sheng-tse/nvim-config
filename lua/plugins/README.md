# Plugin Organization

This directory contains all Neovim plugins organized by category for better maintainability.

## Directory Structure

```
plugins/
├── editor/          # Editor enhancement plugins
│   ├── dial.lua                # Smart increment/decrement
│   ├── telescope-undo.lua      # Undo history browser
│   └── treesitter.lua          # Syntax parsing and highlighting
│
├── lang/            # Language-specific plugins
│   ├── database.lua            # Database UI and tools
│   ├── jupyter.lua             # Jupyter notebook support
│   ├── latex.lua               # LaTeX support with VimTeX
│   └── markdown.lua            # Markdown preview
│
├── lsp/             # LSP and language server configurations
│   ├── java.lua                # Java LSP (jdtls)
│   ├── postgresql.lua          # PostgreSQL/SQL LSP
│   ├── python.lua              # Python LSP (basedpyright)
│   └── semantic-tokens.lua     # Semantic highlighting config
│
└── ui/              # UI enhancement plugins
    └── rainbow-brackets.lua    # Rainbow delimiter colors
```

## PostgreSQL Configuration

PostgreSQL LSP support has been added via `lsp/postgresql.lua`. To use it:

1. Install required tools (handled automatically by Mason):
   - `sql-language-server` - SQL language server
   - `sqlfluff` - SQL linter and formatter

2. Optional: Configure database connections in `lang/database.lua`:
   ```lua
   vim.g.dbs = {
     { name = 'my_db', url = 'postgresql://user:password@localhost:5432/database' },
   }
   ```

3. Database UI keybindings:
   - `<leader>db` - Toggle Database UI
   - `<leader>df` - Find Database Buffer
   - `<leader>dr` - Rename Database Buffer
   - `<leader>dl` - Last Query Info

## Adding New Plugins

When adding new plugins, place them in the appropriate category:

- **editor/**: General editing enhancements (e.g., fuzzy finders, file explorers)
- **lang/**: Language-specific tools (e.g., REPL, formatters, debuggers)
- **lsp/**: LSP configurations and language servers
- **ui/**: Visual enhancements (e.g., themes, statusline, icons)

Each file should export a table of plugin specifications compatible with lazy.nvim.

## Notes

- All plugins are automatically loaded by lazy.nvim
- LSP configurations in `lsp/` are merged with LazyVim defaults
- Plugin files can contain multiple related plugins in a single table
