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

# Check for DMS on Linux and offer installation if missing
DMS_INSTALLED=false
if [ "$OS" = "Linux" ]; then
  if command -v dms &> /dev/null; then
    DMS_INSTALLED=true
    echo "✓ DankMaterialShell (dms) is installed"
  else
    echo "⚠️  DankMaterialShell (dms) is not installed."
    if command -v gum &> /dev/null; then
      if gum confirm "Would you like to install DankMaterialShell now?"; then
        echo "Installing DankMaterialShell..."
        curl -fsSL https://install.danklinux.com | sh
        if command -v dms &> /dev/null; then
          DMS_INSTALLED=true
          echo "✓ DankMaterialShell installed"
        else
          echo "⚠️  Installation may have failed. Please check manually."
        fi
      else
        echo "Skipping DankMaterialShell installation"
      fi
    else
      echo "Note: Install 'gum' to enable interactive DMS installation prompt"
      echo "      Or install DMS manually: curl -fsSL https://install.danklinux.com | sh"
    fi
  fi
  echo ""
fi

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
# Note: dunst, kitty, kvantum, qimgv, hyprpanel are archived (see archived/ directory)
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

# DMS config packages (only stowed if DMS is installed)
DMS_PACKAGES=(
  "dms-config"
  "icons-dms"
  "gtk-dms"
  "environment-dms"
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
  # Use ghostty-raw on macOS (no DMS integration)
  if [ -d "ghostty-raw" ]; then
    echo "Stowing ghostty-raw (macOS uses non-DMS config)..."
    stow -t ~ ghostty-raw || echo "  Warning: Failed to stow ghostty-raw"
  fi
else
  # Use regular ghostty on Linux (with DMS integration)
  if [ -d "ghostty" ]; then
    echo "Stowing ghostty (Linux uses DMS-integrated config)..."
    stow -t ~ ghostty || echo "  Warning: Failed to stow ghostty"
  fi
fi
echo ""

# Platform-specific packages
case "$PLATFORM" in
  linux-wayland)
    echo "=== Stowing Linux packages ==="
    stow_packages "${LINUX_PACKAGES[@]}"
    # Stow DMS packages if DMS is installed
    if [ "$DMS_INSTALLED" = true ]; then
      echo ""
      echo "=== Stowing DMS config packages ==="
      stow_packages "${DMS_PACKAGES[@]}"
    fi
    ;;
  linux)
    echo "=== Stowing Linux packages (excluding Wayland-specific) ==="
    # Linux packages minus Wayland-specific
    for pkg in "${LINUX_PACKAGES[@]}"; do
      if [[ ! " ${WAYLAND_PACKAGES[@]} " =~ " ${pkg} " ]]; then
        stow_packages "$pkg"
      fi
    done
    # Stow DMS packages if DMS is installed
    if [ "$DMS_INSTALLED" = true ]; then
      echo ""
      echo "=== Stowing DMS config packages ==="
      stow_packages "${DMS_PACKAGES[@]}"
    fi
    ;;
  macos)
    echo "=== Unstowing DMS packages (not used on macOS) ==="
    unstow_packages "${DMS_PACKAGES[@]}"
    echo ""
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
