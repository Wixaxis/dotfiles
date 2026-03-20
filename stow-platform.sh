#!/bin/bash
# Platform-aware stow helper script
# This script helps you stow only the packages relevant to your platform

set -e

# Detect platform
OS="$(uname -s)"
PLATFORM=""
DESKTOP=""

case "$OS" in
  Linux)
    # Detect desktop: GNOME vs Hyprland vs other (affects which packages we stow)
    if [[ "${XDG_CURRENT_DESKTOP:-}" == *"GNOME"* ]] || [[ "${XDG_SESSION_DESKTOP:-}" == *"gnome"* ]]; then
      DESKTOP="gnome"
      PLATFORM="linux-gnome"
    elif [[ -n "${HYPRLAND_INSTANCE:-}" ]] || [[ "${XDG_CURRENT_DESKTOP:-}" == *"Hyprland"* ]]; then
      DESKTOP="hyprland"
      PLATFORM="linux-wayland"
    elif [ -n "$WAYLAND_DISPLAY" ] || { [ -n "$XDG_SESSION_TYPE" ] && [ "$XDG_SESSION_TYPE" = "wayland" ]; }; then
      DESKTOP="other"
      PLATFORM="linux-wayland"
    else
      DESKTOP="other"
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

echo "Detected platform: $PLATFORM${DESKTOP:+ (desktop: $DESKTOP)}"
echo ""

# Check for DMS on Linux (only relevant for Hyprland)
DMS_INSTALLED=false
if [ "$OS" = "Linux" ] && [ "$DESKTOP" = "hyprland" ]; then
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
COMMON_PACKAGES=(
  "fastfetch"
  "ghostty"
  "glow"
  "justfile"
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
  "zed"
)

# Linux packages that work on any DE (GNOME, Hyprland, X11, etc.)
LINUX_DE_AGNOSTIC=(
  "arch-update"
  "bash"
  "btop"
  "papes"
  "qt6ct"
  "flameshot"
  "themes"
  "solaar"
)

# Hyprland/Wayland-only packages (not used on GNOME)
LINUX_HYPRLAND_ONLY=(
  "hyprland"
  "rofi"
  "swaync"
  "waybar"
  "thunar"
)

# DMS config packages (only stowed on Hyprland when DMS is installed)
DMS_PACKAGES=(
  "dms-config"
  "icons-dms"
  "gtk-dms"
  "environment-dms"
)

# macOS-specific packages
MACOS_PACKAGES=(
  "zsh"
  "truenas-macos"
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

# Platform-specific packages
case "$PLATFORM" in
  linux-gnome)
    echo "=== GNOME detected: stowing DE-agnostic packages only ==="
    unstow_packages "${DMS_PACKAGES[@]}"
    unstow_packages "${LINUX_HYPRLAND_ONLY[@]}"
    echo ""
    stow_packages "${LINUX_DE_AGNOSTIC[@]}"
    ;;
  linux-wayland)
    if [ "$DESKTOP" = "hyprland" ]; then
      echo "=== Hyprland detected: stowing full Linux + Hyprland set ==="
      stow_packages "${LINUX_DE_AGNOSTIC[@]}"
      stow_packages "${LINUX_HYPRLAND_ONLY[@]}"
      if [ "$DMS_INSTALLED" = true ]; then
        echo ""
        echo "=== Stowing DMS config packages ==="
        stow_packages "${DMS_PACKAGES[@]}"
      fi
    else
      echo "=== Wayland (non-GNOME/non-Hyprland): stowing DE-agnostic only ==="
      unstow_packages "${DMS_PACKAGES[@]}"
      unstow_packages "${LINUX_HYPRLAND_ONLY[@]}"
      echo ""
      stow_packages "${LINUX_DE_AGNOSTIC[@]}"
    fi
    ;;
  linux)
    echo "=== Linux (X11 or other): stowing DE-agnostic only ==="
    unstow_packages "${DMS_PACKAGES[@]}"
    unstow_packages "${LINUX_HYPRLAND_ONLY[@]}"
    echo ""
    stow_packages "${LINUX_DE_AGNOSTIC[@]}"
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
