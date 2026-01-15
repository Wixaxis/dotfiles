# Archived Configurations

This directory contains configuration packages that are not currently in use but are preserved for potential future use or reference.

## Archived Packages

### `dunst/`
- **Purpose**: Dunst notification daemon configuration
- **Reason archived**: Using SwayNC instead for notifications
- **Date archived**: 2025-01-15

### `kitty/`
- **Purpose**: Kitty terminal emulator configuration
- **Reason archived**: Using Ghostty as the primary terminal
- **Date archived**: 2025-01-15

### `githubcli/`
- **Purpose**: GitHub CLI configuration
- **Reason**: Contains sensitive data (hosts.yml) and should not be in dotfiles
- **Status**: Archived - use local config only

### `kvantum/`
- **Purpose**: Kvantum Qt theme engine configuration
- **Reason archived**: Not currently installed or used
- **Date archived**: 2025-01-15

### `qimgv/`
- **Purpose**: qimgv image viewer configuration
- **Reason archived**: Not currently installed or used
- **Date archived**: 2025-01-15

### `hyprpanel/`
- **Purpose**: Hyprpanel panel configuration
- **Reason archived**: Switched back to Waybar as the status bar
- **Date archived**: 2025-01-15

## Restoring Archived Configs

To restore an archived configuration:

1. Move the package back to the repository root:
   ```bash
   mv archived/<package-name> ./
   ```

2. Stow it if needed:
   ```bash
   stow -t ~ <package-name>
   ```

## Notes

- These configs are preserved for reference or future use
- They may be useful when setting up new systems or switching tools
- Configs are kept in their original structure for easy restoration
