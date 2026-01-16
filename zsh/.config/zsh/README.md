# Zsh Modular Configuration

This directory contains the modular zsh configuration system.

## Structure

```
.config/zsh/
├── zshrc              # Main loader - recursively sources modules
└── modules/           # Modular configuration files
    ├── 0-system/      # System-level configs (load first)
    ├── 1-lang/        # Language-specific configs
    └── 2-editor/      # Editor configurations
```

## How It Works

1. `.zshrc` sources `~/.config/zsh/zshrc`
2. `zshrc` recursively loads all `*.zsh` files from `modules/` directories
3. Files are loaded in directory order: `0-system/` → `1-lang/` → `2-editor/`
4. Within each directory, files load in alphabetical order

## Module Categories

### 0-system/ - System Configuration

System-level configurations that should load early:

- `0-oh-my-zsh.zsh` - Oh My Zsh framework initialization
- `1-starship.zsh` - Starship prompt (cross-shell, consistent with Nushell)
- `2-fzf.zsh` - Fuzzy finder configuration (platform-aware)
- `3-path.zsh` - PATH management
- `4-mise.zsh` - mise version manager activation
- `5-aliases.zsh` - Command aliases
- `6-functions.zsh` - Custom shell functions (qa, bw_env)

### 1-lang/ - Language Runtimes

Language-specific configurations (currently empty, ready for future modules):

- Add modules here for: Ruby, Python, Node.js, Go, Rust, etc.
- Version manager configurations (rbenv, pyenv, etc.)

### 2-editor/ - Editor Configurations

Editor and development tool configs (currently empty, ready for future modules):

- Add modules here for: Neovim, Emacs, Cursor, tmux, etc.

## Load Order

Modules in `0-system/` load in this order:

1. `0-oh-my-zsh.zsh` - Must load first (shell framework)
2. `1-starship.zsh` - Loads after Oh My Zsh (prompt initialization)
3. `2-fzf.zsh` - Tools can load after framework
4. `3-path.zsh` - PATH setup
5. `4-mise.zsh` - Version manager (may modify PATH)
6. `5-aliases.zsh` - Aliases
7. `6-functions.zsh` - Custom functions (may use aliases)

## Adding New Modules

1. **Choose the right directory** based on the module's purpose
2. **Create a `.zsh` file** with a descriptive name
3. **Add numeric prefix** if load order matters (e.g., `0-oh-my-zsh.zsh`)
4. **Test** by restarting zsh or sourcing the config

Example:
```zsh
# File: 0-system/my-tool.zsh
# Purpose: Configure my-tool

if command -v my-tool &> /dev/null; then
    # Configuration here
    export MY_TOOL_CONFIG="$HOME/.config/my-tool"
fi
```

## Debugging

Enable debug mode to see which modules are loaded:

```zsh
export DEBUG=true
source ~/.zshrc
```

This will output each module as it's sourced.

## Platform-Specific Modules

The zsh config is platform-aware. Example from `2-fzf.zsh`:

```zsh
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS - Homebrew path
    FZF_BASE="/opt/homebrew/opt/fzf"
else
    # Linux - standard installation
    FZF_BASE="${FZF_BASE:-$HOME/.fzf}"
fi
```

## Related Files

- `.zshrc` - Entry point (sources this directory)
- `.fzf.zsh` - Legacy FZF config (functionality moved to `2-fzf.zsh`)

## See Also

- `CONFIG_STRUCTURE.md` - Detailed structure documentation
- `README.md` - Repository overview
