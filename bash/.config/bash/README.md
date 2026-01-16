# Bash Modular Configuration

This directory contains the modular bash configuration system.

## Structure

```
.config/bash/
├── bashrc              # Main loader - recursively sources modules
├── functions.d/        # Additional function definitions
└── modules/           # Modular configuration files
    ├── 0-system/      # System-level configs (load first)
    ├── 1-lang/        # Language-specific configs
    └── 2-editor/      # Editor configurations
```

## How It Works

1. `.bashrc` sources `~/.config/bash/bashrc`
2. `bashrc` recursively loads all `*.bash` files from `modules/` directories
3. Files are loaded in directory order: `0-system/` → `1-lang/` → `2-editor/`
4. Within each directory, files load in alphabetical order

## Module Categories

### 0-system/ - System Configuration

System-level configurations that should load early:

- `0-xdg.bash` - XDG Base Directory setup
- `aliases.bash` - Command aliases
- `arch.bash` - Arch Linux-specific configs
- `bash.bash` - Bash-specific settings
- `fzf.bash` - Fuzzy finder configuration
- `path.bash` - PATH management
- `z-starship.bash` - Starship prompt setup (loads after oh-my-bash to avoid conflicts)
- `terminal.bash` - Terminal configuration
- `theming.bash` - Theme-related settings

### 1-lang/ - Language Runtimes

Language-specific configurations:

- `bun.bash` - Bun JavaScript runtime
- `dotnet.bash` - .NET SDK
- `go.bash` - Go language
- `java.bash` - Java/JVM
- `npm.bash` - Node.js/npm
- `python.bash` - Python
- `ruby.bash` - Ruby
- `rust.bash` - Rust

### 2-editor/ - Editor Configurations

Editor and development tool configs:

- `cursor.bash` - Cursor IDE integration
- `emacs.bash` - Emacs
- `nvim.bash` - Neovim
- `tmux.bash` - tmux terminal multiplexer

## Adding New Modules

1. **Choose the right directory** based on the module's purpose
2. **Create a `.bash` file** with a descriptive name
3. **Add numeric prefix** if load order matters (e.g., `0-xdg.bash`)
4. **Test** by restarting bash or sourcing the config

Example:
```bash
# File: 0-system/my-tool.bash
# Purpose: Configure my-tool

if command -v my-tool &> /dev/null; then
    # Configuration here
    export MY_TOOL_CONFIG="$HOME/.config/my-tool"
fi
```

## Debugging

Enable debug mode to see which modules are loaded:

```bash
export DEBUG=true
source ~/.bashrc
```

## Platform-Specific Modules

Some modules check the platform:

```bash
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS config
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux config
fi
```

## See Also

- `CONFIG_STRUCTURE.md` - Detailed structure documentation
- `README.md` - Repository overview
