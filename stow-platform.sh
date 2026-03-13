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
# Note: On macOS, ghostty-raw is used instead of ghostty
COMMON_PACKAGES=(
  "fastfetch"
  "glow"
  "justfile"
  "kitty"
  "lazygit"
  "mise"
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
# Note: dunst, kitty, kvantum, qimgv are archived (see archived/ directory)
LINUX_PACKAGES=(
  "arch-update"
  "bash"
  "btop"
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

# Function to unstow packages (removes symlinks created by stow)
unstow_packages() {
  local packages=("$@")
  for package in "${packages[@]}"; do
    if [ -d "$package" ]; then
      if stow -t ~ -D "$package" 2>/dev/null; then
        echo "Unstowed $package"
      fi
      # No warning if nothing was stowed - that's expected
    fi
  done
}

# Stow common packages
echo "=== Stowing common packages ==="
stow_packages "${COMMON_PACKAGES[@]}"

# Platform-specific ghostty selection
if [ "$PLATFORM" = "macos" ]; then
  # Use ghostty-raw on macOS
  if [ -d "ghostty-raw" ]; then
    echo "Stowing ghostty-raw..."
    stow -t ~ ghostty-raw || echo "  Warning: Failed to stow ghostty-raw"
  fi
else
  # Use ghostty-raw on Linux too
  if [ -d "ghostty-raw" ]; then
    echo "Stowing ghostty-raw..."
    stow -t ~ ghostty-raw || echo "  Warning: Failed to stow ghostty-raw"
  fi
fi
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
