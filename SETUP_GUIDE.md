# Setup Guide for New Machines

This guide walks you through setting up these dotfiles on a new Linux machine (like your Chuwi).

## Prerequisites

Before starting, ensure you have:
- **GNU Stow** installed: `sudo pacman -S stow` (or your distro's package manager)
- **Git** installed: `sudo pacman -S git`
- **Ruby with mise** (for scripts): Install mise and Ruby: `mise install ruby@latest`
- **Just** (optional but recommended): `sudo pacman -S just` or install via cargo

## Step-by-Step Setup

### 1. Clone the Repository

If this is the first time setting up:
```bash
git clone <repository-url> ~/dotfiles
cd ~/dotfiles
```

If you already have the repository cloned:
```bash
cd ~/dotfiles
git checkout main  # Ensure you're on the main branch
git pull origin main  # Pull latest changes
```

### 2. Check Current Branch

Verify you're on the unified `main` branch:
```bash
git branch
# Should show: * main
```

### 3. Run Comprehensive Setup Script (Recommended)

The `setup.sh` script is an interactive, idempotent setup script that will:
- Check and install prerequisites (git, stow, mise, paru/brew)
- Verify dotfiles are properly stowed
- Check and install required packages
- Verify mise and Ruby setup
- Check shell configuration
- Guide you through any missing setup

```bash
./setup.sh
```

This script is **idempotent** - you can run it multiple times safely. It will show what's already set up and guide you through what needs to be done.

### 4. Alternative: Run Platform-Aware Installation

If you prefer a simpler, non-interactive approach, use `stow-platform.sh`:

```bash
./stow-platform.sh
```

This will:
- Detect if you're on Linux (Wayland or X11)
- Stow common packages (work on all platforms)
- Stow Linux-specific packages
- Stow Wayland-specific packages only if you're on Wayland

### 4. Verify Installation

Check that symlinks were created:
```bash
ls -la ~/.bashrc  # Should be a symlink
ls -la ~/.config/hypr/  # Should exist if on Wayland
```

### 5. Restart Your Shell

Reload your shell configuration:
```bash
source ~/.bashrc
# Or open a new terminal
```

### 6. Platform-Specific Setup

#### For Wayland/Hyprland Systems:

1. **Restart Hyprland** (if using it):
   ```bash
   hyprctl reload
   ```

2. **Start required services**:
   ```bash
   systemctl --user enable --now hyprpolkitagent.service
   systemctl --user start waybar
   systemctl --user start swaync
   ```

3. **Configure qt6ct** (for Qt application theming):
   ```bash
   qt6ct
   # Set your theme, colors, and fonts
   ```

#### For X11 Systems:

- The script will automatically skip Wayland-specific packages
- You may need to manually configure your window manager/desktop environment

### 7. Install Required Applications

Some packages require specific applications to be installed:

**Common:**
- `ghostty` or your preferred terminal
- `neovim` or `neovide`
- `tmux`
- `yazi` (file manager)
- `rofi` (application launcher)

**Wayland-specific:**
- `hyprland` (window manager)
- `waybar` (status bar)
- `swaync` (notification center)
- `hypridle` (idle daemon)
- `hyprlock` (lock screen)

**Arch-specific:**
- `arch-update` (update notifier)
- `btop` (system monitor)

### 8. Optional: Manual Package Management

If you want to stow/unstow packages manually:

**Stow a specific package:**
```bash
stow -t ~ <package-name>
```

**Unstow a package:**
```bash
stow -D -t ~ <package-name>
```

**List all packages:**
```bash
ls -d */ | grep -v "^archived"
```

## Troubleshooting

### Symlink Conflicts

If you get errors about existing files:
```bash
# Backup existing configs first
mv ~/.bashrc ~/.bashrc.backup

# Then stow
stow -t ~ bash
```

### Platform Detection Issues

If `stow-platform.sh` doesn't detect your platform correctly:
- Check `uname -s` output
- Check `$WAYLAND_DISPLAY` or `$XDG_SESSION_TYPE`
- Manually stow packages as needed

### Missing Dependencies

If scripts fail:
- Check that Ruby/mise is set up: `mise which ruby` or `which ruby`
- Check that required binaries are in PATH
- Review error messages for missing dependencies

## Updating

To update your dotfiles:
```bash
cd ~/dotfiles
git pull origin main
# Re-run stow-platform.sh if new packages were added
./stow-platform.sh
```

## Notes

- **Archived packages**: Some old configs are in `archived/` directory. They won't be stowed automatically.
- **Platform differences**: The unified branch works on all platforms, but some packages are platform-specific.
- **Customizations**: After initial setup, you can customize configs directly in `~/dotfiles/` - changes are immediately reflected via symlinks.

## Next Steps

After setup:
1. Customize theme settings (qt6ct, GTK themes, etc.)
2. Configure application-specific settings
3. Set up any machine-specific overrides if needed
4. Test that everything works as expected
