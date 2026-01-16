# Dotfiles Repository

This repository contains configuration files (dotfiles) for various applications and tools, organized for use with [GNU Stow](https://www.gnu.org/software/stow/). The repository is git-controlled and designed to be easily deployed across different systems.

## Overview

This dotfiles repository uses GNU Stow to manage symbolic links, allowing each configuration package to be installed or removed independently. Each top-level directory represents a "package" that will be symlinked into your home directory when stowed.

**This repository uses a single unified branch (`main`) that works across all platforms** (Linux, macOS). Platform-specific packages are included but should only be stowed on compatible systems. Use the included `stow-platform.sh` script for automatic platform detection and installation.

## Prerequisites

- **GNU Stow** - For managing symbolic links
- **Git** - For version control
- **Ruby** (with mise) - For various automation scripts
- **Just** - For running common tasks (optional but recommended)

## Installation

### Initial Setup

1. Clone this repository:
   ```bash
   git clone <repository-url> ~/dotfiles
   cd ~/dotfiles
   ```

2. **Recommended**: Use the comprehensive setup script:
   ```bash
   ./setup.sh
   ```
   This interactive script will:
   - Check and install prerequisites
   - Verify dotfiles are stowed
   - Check and install required packages
   - Verify mise/Ruby setup
   - Check shell configuration
   - Guide you through any missing setup
   
   **Alternative**: Use the platform-aware installation script:
   ```bash
   ./stow-platform.sh
   ```
   This script automatically detects your platform (Linux, macOS, Wayland, etc.) and stows only the relevant packages.

   **For detailed step-by-step instructions, see [SETUP_GUIDE.md](SETUP_GUIDE.md)**

3. **Alternative**: Install all packages manually:
   ```bash
   stow -t ~ */
   ```
   Note: This will attempt to stow all packages, including platform-specific ones. Some may fail or create conflicts on incompatible platforms.

4. **Alternative**: Install specific packages:
   ```bash
   stow -t ~ bash    # Linux
   stow -t ~ zsh     # macOS (or Linux if you use zsh)
   stow -t ~ hyprland  # Linux/Wayland only
   ```

### Platform-Aware Installation

The `stow-platform.sh` script automatically:
- Detects your operating system (Linux, macOS)
- Detects Wayland vs X11 on Linux
- Stows common packages (work on all platforms)
- Stows platform-specific packages only when appropriate

**Package Categories:**
- **Common packages**: Work on all platforms (ghostty, mise, neovide, nushell, qt6ct, rofi, starship, tmux, yazi, etc.)
- **Linux packages**: Arch-specific (arch-update, btop, etc.)
- **Wayland packages**: Hyprland, Waybar, SwayNC (require Wayland session)
- **macOS packages**: zsh configuration

**Note**: Some packages (dunst, kitty, kvantum, qimgv) have been archived. See `archived/README.md` for details.

### Uninstalling Packages

To remove a package (unlink it):
```bash
stow -D -t ~ <package-name>
```

## Repository Structure

Each top-level directory is a Stow package that will be symlinked into `~` when installed. The structure mirrors the target filesystem layout.

### Archived Configurations

Some configuration packages have been moved to the `archived/` directory. These are configurations that are not currently in use but are preserved for reference or future use. See `archived/README.md` for details.

### Package Descriptions

#### `arch-update/`
- **Purpose**: Configuration for arch-update utility
- **Platform**: Linux (Arch-based distributions only)
- **Files**: `~/.config/arch-update/arch-update.conf`
- **Description**: Settings for managing Arch Linux system updates

#### `bash/`
- **Purpose**: Bash shell configuration
- **Platform**: Linux (can work on macOS if bash is your shell)
- **Files**: 
  - `~/.bashrc` - Main entry point
  - `~/.config/bash/bashrc` - Modular configuration loader
  - `~/.config/bash/modules/` - Modular configuration files organized by category:
    - `0-system/` - System-level configurations (XDG, Arch, Flatpak, FZF, etc.)
    - `1-lang/` - Language-specific configurations (Bun, .NET, Go, Java, npm, Python, Ruby, Rust)
    - `2-editor/` - Editor configurations (Emacs, Neovim, tmux)
- **Note**: The `.bashrc` sources the modular configuration from `~/.config/bash/bashrc`

#### `zsh/`
- **Purpose**: Zsh shell configuration with Oh My Zsh and Powerlevel10k
- **Platform**: macOS (can work on Linux if zsh is your shell)
- **Files**:
  - `~/.zshrc` - Main entry point (sources modular configuration)
  - `~/.config/zsh/zshrc` - Modular configuration loader
  - `~/.config/zsh/modules/` - Modular configuration files organized by category:
    - `0-system/` - System-level configurations (Oh My Zsh, p10k, FZF, PATH, mise, aliases, functions)
    - `1-lang/` - Language-specific configurations (ready for future modules)
    - `2-editor/` - Editor configurations (ready for future modules)
  - `~/.p10k.zsh` - Powerlevel10k theme configuration
  - `~/.fzf.zsh` - Legacy FZF config (functionality also in modules)
- **Note**: 
  - Uses modular structure matching the bash configuration
  - Platform-aware FZF paths (Homebrew on macOS, standard paths on Linux)
  - See `zsh/.config/zsh/README.md` for detailed module documentation

#### `btop/`
- **Purpose**: System monitor configuration
- **Files**: `~/.config/btop/btop.conf`
- **Description**: Configuration for btop resource monitor

#### `dunst/`
- **Purpose**: Desktop notification daemon
- **Files**: `~/.config/dunst/dunstrc`
- **Description**: Notification styling and behavior settings

#### `ghostty/`
- **Purpose**: Ghostty terminal emulator configuration
- **Files**: `~/.config/ghostty/config`
- **Description**: Terminal emulator settings

#### `mise/`
- **Purpose**: mise (formerly rtx) version manager configuration
- **Files**: `~/.config/mise/config.toml`
- **Description**: Configuration for mise tool version management

#### `qt6ct/`
- **Purpose**: Qt6 Configuration Tool settings
- **Files**: `~/.config/qt6ct/` containing:
  - `qt6ct.conf` - Main configuration
  - `colors/` - Color scheme files
  - `palettes/` - Color palette files
- **Description**: Qt application theming and configuration

#### `hyprland/`
- **Purpose**: Hyprland window manager configuration
- **Platform**: Linux (Wayland only)
- **Files**: `~/.config/hypr/` containing:
  - `hyprland.conf` - Main configuration
  - `variables.conf` - Variable definitions
  - `monitors.conf` - Monitor setup
  - `bindings.conf` - Key bindings
  - `base_bindings.conf` - Base binding definitions
  - `window_rules.conf` - Window-specific rules
  - `layer_rules.conf` - Layer shell rules
  - `autostart.conf` - Startup applications
  - `plugins.conf` - Plugin configuration
  - `hypridle.conf` - Idle daemon configuration
  - `hyprlock.conf` - Lock screen configuration
  - `hyprlock/` - Lock screen label configurations
  - `hyprpaper.conf` - Wallpaper daemon configuration
  - `WINDOW_LAYER_RULES_REFERENCE.md` - **Reference guide for window and layer rules syntax (v0.53.0+)**
  - `HYPRPOLKITAGENT_THEMING.md` - **Reference guide for theming hyprpolkitagent**
- **Description**: Complete Hyprland window manager setup for Wayland
- **Note**: Window rules syntax changed significantly in v0.53.0. See `WINDOW_LAYER_RULES_REFERENCE.md` for details.

#### `hyprpanel/`
- **Purpose**: Hyprpanel configuration
- **Files**: 
  - `~/.config/hyprpanel/config.json`
  - `~/.config/hyprpanel/modules.json`
  - `~/.config/hyprpanel/modules.scss`
- **Description**: Panel configuration for Hyprland

#### `hyprpanel_copy/`
- **Purpose**: Backup/copy of hyprpanel configuration
- **Files**: Alternative configuration files
- **Note**: Appears to be a backup or alternative configuration

#### `justfile/`
- **Purpose**: Just command runner configuration
- **Files**: `~/justfile`
- **Description**: Common tasks and shortcuts (see [Justfile Commands](#justfile-commands))

#### `kitty/`
- **Purpose**: Kitty terminal emulator configuration
- **Files**: 
  - `~/.config/kitty/kitty.conf` - Main configuration
  - `~/.config/kitty/current-theme.conf` - Currently active theme
  - `~/.config/kitty/themes/NordicLight.conf` - Theme definitions
- **Description**: Terminal emulator settings with theme support

#### `kvantum/`
- **Purpose**: Kvantum theme engine configuration
- **Files**: `~/.config/Kvantum/` containing:
  - `kvantum.kvconfig` - Main configuration
  - Multiple theme directories (Nordic variants, Utterly-Nord)
- **Description**: Qt application theming via Kvantum

#### `lazygit/`
- **Purpose**: LazyGit terminal UI configuration
- **Files**: `~/.config/lazygit/config.yml`
- **Description**: Git TUI settings and keybindings

#### `neofetch/`
- **Purpose**: Neofetch system information display
- **Files**: `~/.config/neofetch/config.conf`
- **Description**: ASCII art and system info display configuration

#### `neovide/`
- **Purpose**: Neovide GUI editor configuration
- **Files**: `~/.config/neovide/config.toml`
- **Description**: Neovim GUI application settings

#### `nushell/`
- **Purpose**: Nushell shell configuration
- **Platform**: Cross-platform (Linux and macOS)
- **Files**: 
  - **Linux**: `~/.config/nushell/` containing:
    - `config.nu` - Main configuration
    - `env.nu` - Environment variables
    - `envs/` - Environment-specific configurations (Anthropic Claude, editor, mise, path, XDG)
    - `modules/` - Nushell modules (mise, scripts)
    - `sources/` - Source files (aliases, base, completions, prompt)
    - `scripts/` - Nushell scripts
  - **macOS**: `~/Library/Application Support/nushell/` containing wrappers that source from `~/.config/nushell/`
- **Note**: 
  - `history.txt` is gitignored (both paths)
  - macOS uses wrapper files that source the main config from `.config/nushell/` for compatibility

#### `papes/`
- **Purpose**: Wallpaper collection
- **Files**: `~/Pictures/` (wallpaper images)
- **Description**: Collection of wallpapers (PNG, JPG formats)
- **Note**: Screenshots directory is gitignored

#### `qimgv/`
- **Purpose**: qimgv image viewer configuration
- **Files**: 
  - `~/.config/qimgv/qimgv.conf`
  - `~/.config/qimgv/savedState.conf`
  - `~/.config/qimgv/theme.conf`
- **Description**: Image viewer settings and theme

#### `rofi/`
- **Purpose**: Rofi application launcher configuration
- **Files**: 
  - `~/.config/rofi/` - Main configuration files
  - `~/.local/share/rofi/themes/` - Custom theme files
- **Description**: Application launcher with multiple themes and configurations:
  - Multiple color schemes (arc_dark, nord variants)
  - Network manager integration
  - Power menu
  - Custom themes (spotlight, windows11, rounded variants, etc.)

#### `scripts/`
- **Purpose**: Custom automation scripts
- **Files**: `~/scripts/` containing Ruby and Bash scripts
- **Key Scripts**:
  - `brightness.rb` - Screen brightness control
  - `theme_switcher.rb` - Unified theme switching across applications
  - `randomize_wallpaper.rb` - Wallpaper randomization
  - `powermenu.rb` - Power menu functionality
  - `rofi-hyprshot.rb` - Screenshot integration with Rofi
  - `rb-setup-monitors.rb` - Monitor configuration
  - `reload_adjust_swaync.rb` - SwayNC notification center reload
  - `ruby/` - Ruby utility modules (cache_base, ensure_process_up, handle_dmenu, log, rofi_base)
  - `ruby/theme_configs/` - Theme configuration JSON files (nord-dark.json, nord-light.json)
  - `bash/just.bash` - Just integration for Bash
  - `tmux/default_session.sh` - Tmux session management
- **Note**: Uses mise for Ruby version management

#### `solaar/`
- **Purpose**: Solaar Logitech device manager configuration
- **Files**: 
  - `~/.config/solaar/config.yaml`
  - `~/.config/solaar/rules.yaml`
- **Description**: Logitech device configuration and rules

#### `starship/`
- **Purpose**: Starship prompt configuration
- **Files**: `~/.config/starship.toml`
- **Description**: Cross-shell prompt customization

#### `swaync/`
- **Purpose**: SwayNC notification center configuration
- **Files**: 
  - `~/.config/swaync/config.json` - Main configuration
  - `~/.config/swaync/style.css` - Styling
  - `~/.config/swaync/schema/` - Ruby schema definitions
- **Description**: Wayland notification daemon configuration

#### `themes/`
- **Purpose**: GTK theme collection
- **Files**: `~/.themes/` containing multiple GTK themes:
  - Nordic variants (Nordic, Nordic-darker, Nordic-Polar, Nordic-bluish-accent, etc.)
  - Sweet variants (Sweet-Dark, Sweet-mars, Sweet-Ambar-Blue)
  - Material-Black-Blueberry variants
  - Adwaita-dark-nord
  - adw-gtk3 variants
  - oomox-nord-custom
  - Utterly-Nord (Kvantum theme)
- **Description**: Extensive collection of GTK themes with various variants

#### `tmux/`
- **Purpose**: Tmux terminal multiplexer configuration
- **Files**: `~/.config/tmux/` containing:
  - `tmux.conf` - Main configuration
  - `conf.d/` - Modular configuration files:
    - `base.conf` - Base settings
    - `plugins.conf` - Plugin configuration
    - `statusline.conf` - Status line customization
    - `gitmux.yml` - Git integration
- **Description**: Terminal multiplexer with modular configuration

#### `tmuxinator/`
- **Purpose**: Tmuxinator session manager configuration
- **Files**: `~/.config/tmuxinator/default.yml`
- **Description**: Predefined tmux session layouts

#### `waybar/`
- **Purpose**: Waybar status bar configuration
- **Files**: 
  - `~/.config/waybar/config.jsonc` - Main configuration (JSONC format)
  - `~/.config/waybar/style.css` - Styling
  - `~/.config/waybar/themes/` - Theme system:
    - `current-colorscheme.css` - Active colorscheme (symlinked)
    - `current-theme.css` - Active theme (symlinked)
    - `nord/` - Nord theme variants (dark, light, colors, theme)
- **Description**: Wayland status bar with theme support

#### `yazi/`
- **Purpose**: Yazi file manager configuration
- **Files**: `~/.config/yazi/` containing:
  - `yazi.toml` - Main configuration
  - `keymap.toml` - Key bindings
  - `init.lua` - Lua initialization
  - `package.toml` - Package/plugin management
  - `plugins/` - Yazi plugins (bunny, full-border, glow, mdcat, mediainfo, ouch, what-size)
- **Description**: Terminal file manager with Lua configuration and plugins

## Justfile Commands

The `justfile/` package provides a `justfile` in the home directory with common tasks:

- `just update` - Update all system, AUR, and Flatpak packages
- `just cleanup-all` - Remove unused dependencies
- `just dark-mode` - Set screen brightness to minimum
- `just light-mode` - Set screen brightness to maximum
- `just reload-waybar` - Reload Waybar configuration
- `just change-theme` - Run theme switcher
- `just reload-swaync` - Reload SwayNC notification center
- `just test-notifications` - Test notification system
- `just list-fonts` - List all system fonts
- `just randomize-wallpaper` - Randomize wallpapers
- `just ssh-server-local` - SSH into local home server
- `just ssh-server-cloud` - SSH into cloud server via Cloudflare

## Theme System

The repository includes a unified theme switching system via `scripts/theme_switcher.rb`. This script coordinates theme changes across multiple applications:

- **Gradience** - GTK theme application
- **Kitty** - Terminal themes
- **Waybar** - Status bar themes
- **Rofi** - Application launcher themes
- **GNOME** - System color scheme preferences

Theme configurations are stored in `scripts/scripts/ruby/theme_configs/` as JSON files.

## Git Configuration

### Ignored Files

The following files/directories are gitignored (see `.gitignore`):

- `bash/.config/bash/modules/0-system/1-secret_keys.bash` - Secret keys
- `papes/Pictures/screenshots` - Screenshots directory
- `nushell/.config/nushell/history.txt` - Shell history
- `scripts/scripts/debug.log` - Debug logs

### Platform Support

This repository uses a **single unified branch** (`main`) that works on all platforms. Platform-specific packages are included but should only be stowed on compatible systems.

#### Supported Platforms

- **Linux (Arch-based)**: Full support for all packages
- **Linux (Other distros)**: Most packages work, some may need adaptation
- **macOS**: Common packages + macOS-specific configurations
- **Wayland**: Additional Wayland-specific packages (Hyprland, Waybar, SwayNC)

#### Platform-Specific Packages

**Linux-only packages:**
- `arch-update/` - Arch Linux update utility
- `bash/` - Bash shell configuration (can be used on macOS too)
- `btop/` - System monitor
- `dunst/` - Notification daemon
- `ghostty/` - Terminal emulator
- `hyprland/` - Wayland compositor
- `hyprpanel/` - Hyprland panel
- `kvantum/` - Qt theme engine
- `solaar/` - Logitech device manager
- `swaync/` - Wayland notification center
- `waybar/` - Wayland status bar

**macOS-only packages:**
- `zsh/` - Zsh configuration with Oh My Zsh and Powerlevel10k

**Cross-platform packages:**
- All other packages work on both Linux and macOS

#### Platform Detection

The repository includes platform-aware features:
- **`stow-platform.sh`**: Automatically detects platform and stows appropriate packages
- **`justfile`**: Commands detect OS and skip incompatible operations
- **Nushell**: Handles both Linux (`.config/nushell/`) and macOS (`Library/Application Support/nushell/`) paths
- **Zsh FZF integration**: Detects Homebrew vs standard installation paths

## Conventions and Patterns

### Stow Package Structure

Each package directory mirrors the target filesystem structure. For example:
- `bash/.bashrc` → `~/.bashrc` when stowed
- `hyprland/.config/hypr/hyprland.conf` → `~/.config/hypr/hyprland.conf` when stowed

### Modular Configuration

Several packages use modular configuration:
- **Bash**: Modular files in `~/.config/bash/modules/` organized by category (0-system, 1-lang, 2-editor)
- **Zsh**: Modular files in `~/.config/zsh/modules/` organized by category (0-system, 1-lang, 2-editor)
- **Tmux**: Modular files in `~/.config/tmux/conf.d/`
- **Nushell**: Modular files in `~/.config/nushell/envs/`, `modules/`, and `sources/`

**For detailed information about the modular configuration system, see [CONFIG_STRUCTURE.md](CONFIG_STRUCTURE.md)**

### Script Organization

Scripts are primarily written in Ruby (using mise) with some Bash scripts. Ruby scripts use a common base library in `scripts/scripts/ruby/` for shared functionality.

### Theme Management

Themes are managed through:
1. GTK themes in `themes/.themes/`
2. Kvantum themes in `kvantum/.config/Kvantum/`
3. Application-specific themes (Kitty, Waybar, Rofi)
4. Unified switching via `theme_switcher.rb`

## Maintenance Notes

### Adding a New Package

1. Create a new directory at the repository root
2. Mirror the target filesystem structure (e.g., `.config/appname/config.conf`)
3. Add the package to this README
4. Stow it: `stow -t ~ <package-name>`

### Modifying Existing Packages

1. Edit files directly in the repository
2. Changes are immediately reflected via symlinks (if already stowed)
3. Some applications may require reloading (e.g., `just reload-waybar`)

### Platform-Specific Configuration

- **Single branch approach**: All platform configurations are in the `main` branch
- **Conditional stowing**: Use `stow-platform.sh` to automatically stow only relevant packages
- **Platform detection**: Scripts and configurations use OS detection for compatibility
- **Manual selection**: You can manually stow/unstow packages as needed for your setup

## For AI Assistants

When making changes to this repository:

1. **Respect the Stow structure**: Maintain the directory structure that mirrors the target filesystem
2. **Check gitignore**: Ensure sensitive files are properly ignored
3. **Update this README**: When adding new packages or significant changes
4. **Test symlinks**: After changes, verify symlinks are correct
5. **Consider reloads**: Some applications need reloading after config changes (Waybar, SwayNC, etc.)
6. **Theme consistency**: When modifying themes, consider the unified theme system
7. **Modular approach**: Follow existing patterns for modular configuration (Bash, Tmux, Nushell)
8. **Script dependencies**: Ruby scripts use mise - mise automatically manages Ruby versions
9. **Cross-platform**: This is a unified branch that works on all platforms:
   - Use `stow-platform.sh` for automatic platform detection
   - Linux-specific packages won't cause issues on macOS (just don't stow them)
   - macOS-specific packages (zsh) can be used on Linux if desired
   - Platform-aware scripts automatically detect OS and adapt behavior
10. **Package selection**: When adding new packages, consider:
    - Whether it's platform-specific (document in README)
    - Whether it needs platform detection in scripts
    - Whether it should be included in `stow-platform.sh`
11. **Hyprland window/layer rules**: When modifying window or layer rules:
    - **Always check** `hyprland/.config/hypr/WINDOW_LAYER_RULES_REFERENCE.md` first
    - This repository uses v0.53.0+ syntax (`windowrule`, not `windowrulev2`)
    - Plugin effects use `tag -plugin:name:effect` format
    - Use `hyprctl configerrors` to check for syntax errors after changes

## License

[Add your license information here if applicable]
