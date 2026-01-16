# Dotfiles Configuration Structure

This document explains the modular configuration structure used in this dotfiles repository.

## Overview

This repository uses a **modular configuration system** where shell configurations are broken down into small, focused modules organized by category. This approach provides:

- **Maintainability**: Easy to find and modify specific configurations
- **Scalability**: Simple to add new modules without cluttering main config files
- **Consistency**: Same structure across different shells (bash, zsh)
- **Clarity**: Clear separation of concerns

## Directory Structure

### Shell Configurations

Both `bash` and `zsh` follow the same modular structure:

```
{shell}/
├── .{shell}rc                    # Entry point - sources modular config
└── .config/
    └── {shell}/
        ├── {shell}rc             # Main loader - recursively sources modules
        └── modules/
            ├── 0-system/         # System-level configurations
            ├── 1-lang/           # Language-specific configurations
            └── 2-editor/         # Editor configurations
```

### Module Organization

Modules are organized into numbered directories to ensure proper load order:

- **`0-system/`**: System-level configurations that should load first
  - Path management
  - Shell initialization (Oh My Zsh, etc.)
  - Theme/prompt setup
  - System tools (fzf, starship, etc.)
  - Aliases
  - Custom functions

- **`1-lang/`**: Language runtime configurations
  - Ruby, Python, Node.js, Go, Rust, etc.
  - Version managers (mise, rbenv, etc.)

- **`2-editor/`**: Editor and development tool configurations
  - Neovim, Emacs, Cursor
  - tmux, terminal multiplexers

## Module Loading

### How It Works

1. **Entry Point** (`.zshrc` or `.bashrc`):
   - Checks if running interactively
   - Sources the main loader: `~/.config/{shell}/{shell}rc`

2. **Main Loader** (`~/.config/{shell}/{shell}rc`):
   - Recursively walks through `modules/` directories
   - Sources all valid `*.{shell}` files in order
   - Files are loaded in filesystem order (alphabetical)

3. **Module Files**:
   - Must have extension `.zsh` or `.bash` (depending on shell)
   - Must be readable
   - Loaded in directory order: `0-system/` → `1-lang/` → `2-editor/`

### Load Order Example

For zsh, modules load in this order:
```
0-system/0-oh-my-zsh.zsh    # First: Shell framework
0-system/1-p10k.zsh          # Second: Theme (depends on Oh My Zsh)
0-system/2-fzf.zsh           # Third: Tools
0-system/3-path.zsh          # Fourth: PATH setup
0-system/4-mise.zsh          # Fifth: Version manager
0-system/5-aliases.zsh        # Sixth: Aliases
0-system/6-functions.zsh      # Last: Custom functions
1-lang/*.zsh                 # Then language configs
2-editor/*.zsh               # Finally editor configs
```

## Creating New Modules

### Step 1: Choose the Right Directory

- **System-level configs** → `0-system/`
- **Language runtimes** → `1-lang/`
- **Editors/tools** → `2-editor/`

### Step 2: Name Your Module

Use descriptive names with optional numeric prefixes for ordering:
- `0-oh-my-zsh.zsh` (loads first)
- `1-p10k.zsh` (loads second)
- `aliases.zsh` (loads alphabetically)

### Step 3: Write the Module

Keep modules focused and single-purpose:

```bash
# Good: Single-purpose module
# File: 0-system/aliases.zsh
alias ll='ls -lah'
alias gs='git status'

# Avoid: Multiple unrelated things
# File: 0-system/misc.zsh  ❌
# (Don't create "misc" or "other" modules)
```

### Step 4: Test

After creating a module:
1. Restart your shell or source the config
2. Verify the module loads without errors
3. Test the functionality

## Module Conventions

### Best Practices

1. **Keep modules small**: One concern per file
2. **Use comments**: Explain what the module does
3. **Check dependencies**: Verify tools exist before using them
4. **Platform awareness**: Use `$OSTYPE` checks for cross-platform configs
5. **Error handling**: Don't fail silently if something is missing

### Example Module Template

```bash
# Module: {description}
# Purpose: {what this module does}
# Dependencies: {list any dependencies}

# Check if tool exists
if command -v {tool} &> /dev/null; then
    # Configuration here
else
    [ "${DEBUG:-false}" = "true" ] && echo "{tool} not found"
fi
```

## Debugging

### Enable Debug Mode

Set `DEBUG=true` to see which modules are being loaded:

```bash
export DEBUG=true
source ~/.zshrc
```

This will output:
```
Sourcing /Users/wixaxis/.config/zsh/modules/0-system/0-oh-my-zsh.zsh
Sourcing /Users/wixaxis/.config/zsh/modules/0-system/1-p10k.zsh
...
```

### Common Issues

1. **Module not loading**: Check file extension (must be `.zsh` or `.bash`)
2. **Wrong load order**: Use numeric prefixes (e.g., `0-`, `1-`)
3. **Circular dependencies**: Avoid modules sourcing each other
4. **Path issues**: Use absolute paths or `$HOME` in modules

## Platform-Specific Modules

Some modules may be platform-specific. Use conditional loading:

```bash
# Platform-specific module
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS-specific config
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux-specific config
fi
```

Or create separate files:
- `0-system/path-macos.zsh`
- `0-system/path-linux.zsh`

The loader will source both, and each can check the platform.

## Comparison: Bash vs Zsh

Both shells use identical structure:

| Aspect | Bash | Zsh |
|--------|------|-----|
| Entry point | `.bashrc` | `.zshrc` |
| Main loader | `.config/bash/bashrc` | `.config/zsh/zshrc` |
| Module extension | `.bash` | `.zsh` |
| Module dirs | `modules/0-system/` etc. | `modules/0-system/` etc. |

This consistency makes it easy to:
- Port configs between shells
- Maintain both shells
- Understand the structure quickly

## Migration Notes

When migrating from a monolithic config file:

1. **Identify logical sections**: Group related configs
2. **Create modules**: One file per logical section
3. **Test incrementally**: Add modules one at a time
4. **Verify functionality**: Ensure everything still works
5. **Clean up**: Remove old monolithic file

## See Also

- `README.md` - General repository documentation
- `SETUP_GUIDE.md` - Installation and setup instructions
- Individual module files - Each module should have comments explaining its purpose
