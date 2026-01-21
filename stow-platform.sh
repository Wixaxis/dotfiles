#!/bin/bash
# Platform-aware stow helper script
# This script helps you stow only the packages relevant to your platform

set -e

# Detect platform
OS="$(uname -s)"
PLATFORM=""

case "$OS" in
  Linux)
    # Detect if running Wayland
    if [ -n "$WAYLAND_DISPLAY" ] || [ -n "$XDG_SESSION_TYPE" ] && [ "$XDG_SESSION_TYPE" = "wayland" ]; then
      PLATFORM="linux-wayland"
    else
      PLATFORM="linux"
    fi
    ;;
  Darwin)
    PLATFORM="macos"
    ;;
  *)
    PLATFORM="unknown"
    ;;
esac

echo "Detected platform: $PLATFORM"
echo ""

# Common packages (work on all platforms)
COMMON_PACKAGES=(
  "fastfetch"
  "ghostty"
  "glow"
  "justfile"
  "kitty"
  "lazygit"
  "mise"
  "neofetch"
  "neovide"
  "nushell"
  "scripts"
  "ssh"
  "starship"
  "tmux"
  "tmuxinator"
  "yazi"
)

# Linux-specific packages
# Note: dunst, kitty, kvantum, qimgv, hyprpanel are archived (see archived/ directory)
LINUX_PACKAGES=(
  "arch-update"
  "bash"
  "btop"
  "ghostty"
  "papes"
  "qimgv"
  "qt6ct"
  "rofi"
  "themes"
  "thunar"
  "hyprland"
  "solaar"
  "swaync"
  "waybar"
)

# macOS-specific packages
MACOS_PACKAGES=(
  "zsh"
)

# Wayland-specific packages (subset of Linux)
WAYLAND_PACKAGES=(
  "hyprland"
  "hyprpanel"
  "swaync"
  "waybar"
)

# Function to stow packages
stow_packages() {
  local packages=("$@")
  for package in "${packages[@]}"; do
    if [ -d "$package" ]; then
      echo "Stowing $package..."
      stow -t ~ "$package" || echo "  Warning: Failed to stow $package"
    else
      echo "  Skipping $package (not found)"
    fi
  done
}

# Stow common packages
echo "=== Stowing common packages ==="
stow_packages "${COMMON_PACKAGES[@]}"
echo ""

# Platform-specific packages
case "$PLATFORM" in
  linux-wayland)
    echo "=== Stowing Linux packages ==="
    stow_packages "${LINUX_PACKAGES[@]}"
    ;;
  linux)
    echo "=== Stowing Linux packages (excluding Wayland-specific) ==="
    # Linux packages minus Wayland-specific
    for pkg in "${LINUX_PACKAGES[@]}"; do
      if [[ ! " ${WAYLAND_PACKAGES[@]} " =~ " ${pkg} " ]]; then
        stow_packages "$pkg"
      fi
    done
    ;;
  macos)
    echo "=== Stowing macOS packages ==="
    stow_packages "${MACOS_PACKAGES[@]}"
    echo ""
    echo "Note: On macOS, you may want to stow 'bash' if you use bash alongside zsh"
    ;;
  *)
    echo "Unknown platform. Stowing only common packages."
    echo "You may need to manually stow platform-specific packages."
    ;;
esac

echo ""
echo "Done! Some packages may require application restart to take effect."
