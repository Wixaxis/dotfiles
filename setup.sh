#!/usr/bin/env bash
# Comprehensive dotfiles setup script
# Idempotent - safe to run multiple times
# Supports Arch Linux (pacman/paru) and macOS (brew)

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Detect platform
detect_platform() {
    if [[ "$(uname -s)" == "Linux" ]]; then
        if command -v pacman &> /dev/null; then
            PLATFORM="arch"
        else
            PLATFORM="linux"
        fi
    elif [[ "$(uname -s)" == "Darwin" ]]; then
        PLATFORM="macos"
    else
        PLATFORM="unknown"
    fi
    echo "$PLATFORM"
}

PLATFORM=$(detect_platform)

# Print functions
info() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warning() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; }
section() { echo -e "\n${BLUE}━━━ $1 ━━━${NC}"; }

# Check if command exists
has_command() {
    command -v "$1" &> /dev/null
}

# Check if package is installed (Arch)
is_installed_arch() {
    if has_command paru; then
        paru -Qi "$1" &> /dev/null
    else
        pacman -Qi "$1" &> /dev/null 2>&1
    fi
}

# Check if package is installed (macOS)
is_installed_macos() {
    brew list "$1" &> /dev/null 2>&1
}

# Check if symlink exists and points to dotfiles
is_stowed() {
    local target="$1"
    local source="$2"
    if [[ -L "$target" ]] && [[ "$(readlink -f "$target")" == "$(readlink -f "$source")" ]]; then
        return 0
    fi
    return 1
}

# Install package (Arch)
install_arch() {
    local pkg="$1"
    if has_command paru; then
        info "Installing $pkg with paru..."
        paru -S --noconfirm "$pkg"
    else
        error "paru not found! Please install paru first:"
        echo "  git clone https://aur.archlinux.org/paru.git /tmp/paru"
        echo "  cd /tmp/paru && makepkg -si"
        exit 1
    fi
}

# Install package (macOS)
install_macos() {
    local pkg="$1"
    info "Installing $pkg with brew..."
    brew install "$pkg"
}

# Check prerequisites
check_prerequisites() {
    section "Checking Prerequisites"
    
    local missing=()
    
    # Common prerequisites
    if ! has_command git; then
        missing+=("git")
    else
        success "git is installed"
    fi
    
    if ! has_command stow; then
        missing+=("stow")
    else
        success "stow is installed"
    fi
    
    if ! has_command mise; then
        missing+=("mise")
    else
        success "mise is installed"
    fi
    
    # Platform-specific prerequisites
    if [[ "$PLATFORM" == "arch" ]]; then
        if ! has_command paru; then
            error "paru is not installed!"
            echo "  Install paru:"
            echo "    git clone https://aur.archlinux.org/paru.git /tmp/paru"
            echo "    cd /tmp/paru && makepkg -si"
            exit 1
        else
            success "paru is installed"
        fi
    elif [[ "$PLATFORM" == "macos" ]]; then
        if ! has_command brew; then
            error "Homebrew is not installed!"
            echo "  Install Homebrew:"
            echo "    /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            exit 1
        else
            success "Homebrew is installed"
        fi
    fi
    
    # Install missing prerequisites
    if [[ ${#missing[@]} -gt 0 ]]; then
        warning "Missing prerequisites: ${missing[*]}"
        read -p "Install missing prerequisites? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            for pkg in "${missing[@]}"; do
                if [[ "$PLATFORM" == "arch" ]]; then
                    install_arch "$pkg"
                elif [[ "$PLATFORM" == "macos" ]]; then
                    install_macos "$pkg"
                fi
            done
        else
            error "Please install missing prerequisites and run this script again"
            exit 1
        fi
    fi
}

# Check if dotfiles are stowed
check_stowed() {
    section "Checking Dotfiles Installation"
    
    local dotfiles_dir
    dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local home_dir="$HOME"
    
    local packages=(
        "bash:.bashrc"
        "ghostty:.config/ghostty"
        "hyprland:.config/hypr"
        "waybar:.config/waybar"
        "swaync:.config/swaync"
        "tmux:.config/tmux"
        "yazi:.config/yazi"
        "starship:.config/starship.toml"
    )
    
    local not_stowed=()
    
    for package_info in "${packages[@]}"; do
        IFS=':' read -r package target <<< "$package_info"
        local package_dir="$dotfiles_dir/$package"
        local target_path="$home_dir/$target"
        
        if [[ -d "$package_dir" ]]; then
            if is_stowed "$target_path" "$package_dir/$target"; then
                success "$package is stowed"
            else
                not_stowed+=("$package")
                warning "$package is not stowed (target: $target)"
            fi
        fi
    done
    
    if [[ ${#not_stowed[@]} -gt 0 ]]; then
        warning "Some packages are not stowed: ${not_stowed[*]}"
        read -p "Stow missing packages? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cd "$dotfiles_dir"
            for package in "${not_stowed[@]}"; do
                info "Stowing $package..."
                stow -t ~ "$package" || warning "Failed to stow $package"
            done
            success "Packages stowed"
        fi
    fi
}

# Check required packages
check_packages() {
    section "Checking Required Packages"
    
    # Common packages
    local common_packages=(
        "git"
        "stow"
        "mise"
        "tmux"
        "ghostty"
        "yazi"
    )
    
    # Arch-specific packages
    local arch_packages=(
        "bash"
        "hyprland"
        "waybar"
        "swaync"
        "hypridle"
        "hyprlock"
        "hyprpolkitagent"
        "btop"
        "rofi"
        "starship"
    )
    
    # macOS-specific packages
    local macos_packages=(
        "zsh"
    )
    
    local missing=()
    
    # Check common packages
    for pkg in "${common_packages[@]}"; do
        if has_command "$pkg"; then
            success "$pkg is installed"
        else
            missing+=("$pkg")
            warning "$pkg is not installed"
        fi
    done
    
    # Check platform-specific packages
    if [[ "$PLATFORM" == "arch" ]]; then
        for pkg in "${arch_packages[@]}"; do
            if is_installed_arch "$pkg" || has_command "$pkg"; then
                success "$pkg is installed"
            else
                missing+=("$pkg")
                warning "$pkg is not installed"
            fi
        done
    elif [[ "$PLATFORM" == "macos" ]]; then
        for pkg in "${macos_packages[@]}"; do
            if is_installed_macos "$pkg" || has_command "$pkg"; then
                success "$pkg is installed"
            else
                missing+=("$pkg")
                warning "$pkg is not installed"
            fi
        done
    fi
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        warning "Missing packages: ${missing[*]}"
        read -p "Install missing packages? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            for pkg in "${missing[@]}"; do
                if [[ "$PLATFORM" == "arch" ]]; then
                    install_arch "$pkg"
                elif [[ "$PLATFORM" == "macos" ]]; then
                    install_macos "$pkg"
                fi
            done
        fi
    fi
}

# Check mise setup
check_mise() {
    section "Checking mise Setup"
    
    if ! has_command mise; then
        error "mise is not installed"
        return 1
    fi
    
    success "mise is installed"
    
    # Check if Ruby is installed via mise
    if mise which ruby &> /dev/null; then
        local ruby_version
        ruby_version=$(mise which ruby)
        success "Ruby is installed via mise: $ruby_version"
    else
        warning "Ruby is not installed via mise"
        read -p "Install Ruby with mise? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            mise install ruby@latest
            success "Ruby installed"
        fi
    fi
    
    # Check if mise is activated in shell
    if [[ -n "${MISE_SHELL:-}" ]] || command -v mise &> /dev/null && mise env | grep -q "PATH"; then
        success "mise is activated in shell"
    else
        warning "mise may not be activated in your shell"
        info "Make sure you have: eval \"\$(mise activate bash)\" in your shell config"
    fi
}

# Check shell configuration
check_shell() {
    section "Checking Shell Configuration"
    
    local shell_name
    shell_name=$(basename "$SHELL")
    
    if [[ "$PLATFORM" == "arch" ]]; then
        if [[ "$shell_name" == "bash" ]]; then
            if [[ -f "$HOME/.bashrc" ]] && grep -q "bashrc" "$HOME/.bashrc"; then
                success "Bash configuration is set up"
            else
                warning "Bash configuration may not be complete"
            fi
        fi
    elif [[ "$PLATFORM" == "macos" ]]; then
        if [[ "$shell_name" == "zsh" ]]; then
            if [[ -f "$HOME/.zshrc" ]]; then
                success "Zsh configuration is set up"
            else
                warning "Zsh configuration may not be complete"
            fi
        fi
    fi
}

# Check Wayland-specific setup (Arch only)
check_wayland() {
    if [[ "$PLATFORM" != "arch" ]]; then
        return 0
    fi
    
    section "Checking Wayland Setup"
    
    if [[ -n "${WAYLAND_DISPLAY:-}" ]] || [[ "${XDG_SESSION_TYPE:-}" == "wayland" ]]; then
        success "Running on Wayland"
        
        # Check Hyprland services
        if systemctl --user is-active --quiet hyprpolkitagent.service 2>/dev/null; then
            success "hyprpolkitagent service is running"
        else
            warning "hyprpolkitagent service is not running"
            info "Start it with: systemctl --user enable --now hyprpolkitagent.service"
        fi
        
        # Check qt6ct configuration
        if [[ -f "$HOME/.config/qt6ct/qt6ct.conf" ]]; then
            success "qt6ct is configured"
        else
            warning "qt6ct is not configured"
            info "Configure it with: qt6ct"
        fi
    else
        info "Not running on Wayland (or not in Wayland session)"
    fi
}

# Main function
main() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║         Dotfiles Setup & Verification Script            ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    info "Detected platform: $PLATFORM"
    
    if [[ "$PLATFORM" == "unknown" ]]; then
        error "Unknown platform. This script supports Arch Linux and macOS only."
        exit 1
    fi
    
    check_prerequisites
    check_stowed
    check_packages
    check_mise
    check_shell
    check_wayland
    
    section "Setup Complete"
    success "All checks completed!"
    info "You may need to restart your shell or log out/in for some changes to take effect"
    
    if [[ "$PLATFORM" == "arch" ]] && [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
        info "For Wayland/Hyprland, you may want to run:"
        echo "  hyprctl reload"
        echo "  systemctl --user restart hyprpolkitagent"
    fi
}

# Run main function
main
