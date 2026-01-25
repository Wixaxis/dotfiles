# DankMaterialShell (DMS) Documentation

## What is DankMaterialShell?

**DankMaterialShell** is a complete desktop shell for Wayland compositors built with [Quickshell](https://quickshell.org/) and [Go](https://go.dev/). It's a unified replacement for multiple desktop components that you'd normally configure separately.

### What DMS Replaces

DMS replaces and integrates:
- **waybar** - Status bar/panel
- **swaylock** - Lock screen
- **swayidle** - Idle management
- **mako** - Notification daemon
- **fuzzel/rofi** - Application launcher
- **polkit** - Authentication agent
- Other desktop components

### Repository

- **GitHub**: [AvengeMedia/DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell)
- **Website**: [danklinux.com](https://danklinux.com)
- **Documentation**: [danklinux.com/docs](https://danklinux.com/docs/)

## Features

### Dynamic Theming
- Wallpaper-based color schemes that automatically theme GTK, Qt, terminals, editors (VSCode, VSCodium), and more
- Uses [matugen](https://github.com/InioX/matugen) and dank16 for theme generation
- The `dankcolors` theme in Ghostty is part of this theming system

### System Monitoring
- Real-time CPU, RAM, GPU metrics and temperatures
- Process list with search and management
- Uses [dgop](https://github.com/AvengeMedia/dgop) for monitoring

### Powerful Launcher (Spotlight)
- Spotlight-style search for:
  - Applications
  - Files (via [dsearch](https://github.com/AvengeMedia/danksearch))
  - Emojis
  - Running windows
  - Calculator
  - Commands
- Extensible with plugins

### Control Center
- Unified interface for:
  - Network management
  - Bluetooth
  - Audio devices
  - Display settings
  - Night mode

### Smart Notifications
- Notification center with grouping
- Rich text support
- Keyboard navigation

### Media Integration
- MPRIS player controls
- Calendar sync
- Weather widgets
- Clipboard history with image previews

### Session Management
- Lock screen
- Idle detection
- Auto-lock/suspend with separate AC/battery settings
- Greeter support

### Plugin System
- Extend functionality via [plugin registry](https://plugins.danklinux.com)

## Installation

DMS was installed via:
```bash
curl -fsSL https://install.danklinux.com | sh
```

This installs DMS and all dependencies on Arch, Fedora, Debian, Ubuntu, openSUSE, or Gentoo.

## Configuration Files

### Hyprland Integration

DMS created configuration files in `~/.config/hypr/dms/`:

#### `dms/colors.conf`
Auto-generated color scheme based on wallpaper. Defines:
- `$primary` - Primary accent color
- `$outline` - Border/outline color
- `$error` - Error/warning color
- Active/inactive border colors
- Group border colors

**Note**: This file is auto-generated. To override, remove `source = ./dms/colors.conf` from `hyprland.conf`.

#### `dms/binds.conf`
Keybindings for DMS functionality:
- **SUPER + Space** - Toggle Spotlight launcher
- **SUPER + M** - Toggle process list
- **SUPER + N** - Toggle notifications
- **SUPER + V** - Toggle clipboard
- **SUPER + X** - Toggle power menu
- **SUPER + Y** - Wallpaper selector
- **SUPER + ,** - Toggle settings/control center
- **SUPER + TAB** - Toggle workspace overview
- **SUPER + ALT + L** - Lock screen
- **Print** - Screenshot (current window)
- **CTRL + Print** - Full screenshot
- **ALT + Print** - Window screenshot
- Media keys for audio/brightness control

#### `dms/layout.conf`
Window layout settings:
- Gaps (in: 4, out: 4)
- Border size: 2
- Decoration rounding: 12

#### `dms/outputs.conf`
Monitor configuration (auto-detected)

#### `dms/cursor.conf`
Cursor theme and size settings

### Ghostty Integration

DMS modified the Ghostty config to use the `dankcolors` theme, which integrates with DMS's dynamic theming system.

**Changes made during installation:**
- Theme changed from `Nord` to `dankcolors`
- Added Material 3 UI elements
- Updated window configuration
- Added shell integration features

The `dankcolors` theme file is located at:
```
~/.config/ghostty/themes/dankcolors
```

## Command Line Interface

### Basic Commands

```bash
# Start the shell
dms run

# IPC commands (control running DMS)
dms ipc call spotlight toggle
dms ipc call audio setvolume 50
dms ipc call wallpaper set /path/to/image.jpg
dms ipc call notifications toggle
dms ipc call clipboard toggle
dms ipc call lock lock
dms ipc call hypr toggleOverview
dms ipc call processlist focusOrToggle
dms ipc call powermenu toggle
dms ipc call settings focusOrToggle

# Brightness control
dms brightness list          # List available displays
dms brightness increment 5   # Increase brightness by 5%
dms brightness decrement 5   # Decrease brightness by 5%

# Plugins
dms plugins search          # Browse plugin registry
dms plugins list            # List installed plugins

# Color utilities
dms color <command>         # Color manipulation tools
dms dank16 <command>        # Generate Base16 color palettes
dms matugen <command>       # Generate Material Design themes

# Configuration
dms config <command>        # Configuration utilities
dms keybinds <command>      # Manage keybinds and cheatsheets

# Diagnostics
dms doctor                  # Diagnose DMS installation and dependencies
```

### IPC Commands Reference

Common IPC calls:
- `dms ipc call spotlight toggle` - Toggle launcher
- `dms ipc call audio mute` - Toggle mute
- `dms ipc call audio increment <value>` - Increase volume
- `dms ipc call audio decrement <value>` - Decrease volume
- `dms ipc call mpris playPause` - Play/pause media
- `dms ipc call mpris next` - Next track
- `dms ipc call mpris previous` - Previous track
- `dms ipc call brightness increment <value> <display>` - Increase brightness
- `dms ipc call brightness decrement <value> <display>` - Decrease brightness
- `dms ipc call notifications toggle` - Toggle notification center
- `dms ipc call clipboard toggle` - Toggle clipboard manager
- `dms ipc call lock lock` - Lock screen
- `dms ipc call hypr toggleOverview` - Toggle workspace overview
- `dms ipc call processlist focusOrToggle` - Toggle process manager
- `dms ipc call powermenu toggle` - Toggle power menu
- `dms ipc call settings focusOrToggle` - Toggle control center
- `dms ipc call dankdash wallpaper` - Open wallpaper selector
- `dms ipc call notepad toggle` - Toggle notepad

## Keybindings

### Launcher & Navigation
- **SUPER + Space** - Spotlight launcher
- **SUPER + TAB** - Workspace overview
- **SUPER + ,** - Control center/settings

### System
- **SUPER + M** - Process list
- **SUPER + N** - Notifications
- **SUPER + SHIFT + N** - Notepad
- **SUPER + V** - Clipboard manager
- **SUPER + X** - Power menu
- **SUPER + Y** - Wallpaper selector
- **SUPER + ALT + L** - Lock screen
- **SUPER + SHIFT + /** - Keybinds cheatsheet

### Screenshots
- **Print** - Screenshot (current window)
- **CTRL + Print** - Full screenshot
- **ALT + Print** - Window screenshot

### Media Controls
- **XF86AudioMute** - Toggle mute
- **XF86AudioLowerVolume** - Decrease volume
- **XF86AudioRaiseVolume** - Increase volume
- **XF86AudioPlay/Pause** - Play/pause
- **XF86AudioNext** - Next track
- **XF86AudioPrev** - Previous track
- **XF86MonBrightnessUp/Down** - Brightness control

## Customization

### Overriding DMS Config

The files in `~/.config/hypr/dms/` are auto-generated. To override:

1. Remove the `source = ./dms/<file>.conf` line from `hyprland.conf`
2. Add your custom configuration directly in `hyprland.conf` or a separate file

Example: To override colors, remove:
```hyprland
source = ./dms/colors.conf
```

And add your own color definitions in `hyprland.conf`.

### Theming

DMS uses dynamic theming based on wallpapers. The theme is generated using:
- **matugen** - Material Design theme generator
- **dank16** - Base16 color palette generator

To regenerate themes:
```bash
dms matugen <command>
dms dank16 <command>
```

### Plugins

Browse and install plugins:
```bash
dms plugins search
```

See [plugin registry](https://plugins.danklinux.com) for available plugins.

## Troubleshooting

### Check DMS Status
```bash
dms doctor
```

This diagnoses installation and dependencies.

### Kill DMS Processes
```bash
dms kill
```

### Debug Server
```bash
dms debug-srv
```

### View Logs
Check system logs or DMS output for errors.

## Documentation Links

- **Main Docs**: https://danklinux.com/docs/
- **Installation Guide**: https://danklinux.com/docs/dankmaterialshell/installation
- **Compositor Config**: https://danklinux.com/docs/dankmaterialshell/compositors
- **Keybinds & IPC**: https://danklinux.com/docs/dankmaterialshell/keybinds-ipc
- **Application Themes**: https://danklinux.com/docs/dankmaterialshell/application-themes
- **Custom Themes**: https://danklinux.com/docs/dankmaterialshell/custom-themes
- **Plugins Overview**: https://danklinux.com/docs/dankmaterialshell/plugins-overview

## Notes

- DMS config files in `dms/` directory are auto-generated - don't edit manually
- The `dankcolors` theme in Ghostty integrates with DMS's theming system
- DMS replaces waybar, so if you had waybar configured, it's now handled by DMS
- All DMS windows are configured to float by default (see `hyprland.conf` line 110)
