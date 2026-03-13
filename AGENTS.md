# Agent Instructions

## Repository Overview

This is a **dotfiles repository** managed with GNU Stow. It contains configuration files for various tools (Hyprland, Ghostty, Tmux, etc.) and custom scripts (Ruby, Bash).

## Build/Test/Lint Commands

### Task Runner (Just)
```bash
# List all available tasks
just

# Common tasks
just update              # Update system packages (Linux)
just cleanup-all         # Remove unused dependencies (Linux)
just reload-waybar       # Reload waybar config
just reload-swaync       # Reload swaync config
just test-notifications  # Test notification system
just randomize-wallpaper # Change wallpaper
```

### Code Quality
```bash
# Shell script linting
shellcheck *.sh scripts/scripts/*.sh

# Ruby syntax check
ruby -c scripts/scripts/*.rb

# Test config syntax
hyprctl reload --dry-run 2>&1  # Hyprland
ghostty +validate           # Ghostty
```

### Running Single Scripts
```bash
# Ruby scripts (use mise for version management)
mise exec ruby@latest -- ruby scripts/scripts/script_name.rb

# Or directly (shebang handles mise)
./scripts/scripts/script_name.rb

# Bash scripts
bash scripts/scripts/script_name.sh
bash setup.sh
```

## Code Style Guidelines

### General Principles
- **Conciseness**: Keep code minimal and clean, remove redundancy
- **Modularity**: Group related functionality, changes in one place
- **Idempotency**: Scripts safe to run multiple times
- **Platform Awareness**: Support Arch Linux (pacman/paru) and macOS (brew)

### Ruby Scripts
- Use shebang: `#!/usr/bin/env -S mise exec ruby@latest -- ruby`
- Include: `# frozen_string_literal: true`
- Use lambdas for functional patterns: `->(args) { ... }`
- Load shared libraries from `/home/wixaxis/scripts/ruby/`
- Handle errors gracefully with custom exception classes

### Bash Scripts
- Always use: `set -euo pipefail`
- Check command existence: `command -v cmd &> /dev/null`
- Use colors for output (info, success, warning, error)
- Platform detection: `uname -s` and environment variables
- Make interactive when appropriate (ask before installing)

### Configuration Files
- Group related settings with visual separators
- Use clear section headers: `# === SECTION NAME ===`
- Keep active config clean, archive unused configs
- Mirror target filesystem structure
- Consistent naming conventions (kebab-case for files)

### File Organization
- One package = one top-level directory
- Use `.config/` subdirectories appropriately
- Scripts location:
  - Ruby: `scripts/scripts/*.rb`
  - Bash: `scripts/scripts/*.sh` or package root
  - Shared Ruby libs: `scripts/scripts/ruby/*.rb`

### Git Workflow
- Use GNU Stow for symlink management
- Never track: API keys, passwords, sensitive data
- Keep `.gitignore` up to date
- Test symlinks after stowing: `ls -la ~ | grep dotfiles`

### Documentation
- Propose changes before applying for significant modifications
- Explain what changed and why
- Use checkmarks (✓) for completed items
- Update README for significant features
- Create reference markdown files for complex topics

### Sensitive Data Handling
- **NEVER** track: Authentication tokens, API keys, passwords
- **NEVER** track: Application-specific sensitive configs (gh hosts.yml)
- **NEVER** track: User-specific data, large cache directories
- Add patterns to `.gitignore` with documentation

### Platform-Specific Patterns
```bash
# Platform detection
OS="$(uname -s)"
case "$OS" in
  Linux) PLATFORM="linux" ;;
  Darwin) PLATFORM="macos" ;;
esac

# Package management
if command -v paru &> /dev/null; then
  paru -S --noconfirm package
elif command -v brew &> /dev/null; then
  brew install package
fi
```

## Verification Checklist

Before committing:
- [ ] Test scripts work (run commands, check syntax)
- [ ] Verify symlinks correct after stowing
- [ ] Check for syntax errors in configs
- [ ] Ensure platform detection works
- [ ] No sensitive data in commits

## Tool Preferences

- **Version Management**: mise (not rbenv)
- **Task Runner**: just (justfile in repo root)
- **AUR Helper**: paru (Arch Linux)
- **Symlink Manager**: GNU Stow
- **Script Languages**: Ruby (with mise), Bash

## Communication

- Be direct and clear
- Show what changed (diffs when helpful)
- Provide actionable next steps
- When uncertain: ask rather than guess
- Respect user decisions
