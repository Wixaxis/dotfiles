#!/usr/bin/env bash
# Comprehensive dotfiles setup script
# Idempotent - safe to run multiple times
# Supports Arch Linux (pacman/paru) and macOS (brew)
#
# Shell Configuration:
#   - All tools respect the system's default shell ($SHELL)
#   - No explicit shell settings - uses whatever the user has configured
#   - Ghostty: Uses $SHELL automatically (no config needed)
#   - Tmux: Uses $SHELL automatically (no config needed)

set -euo pipefail

# ============================================================================
# GUM CHECK - MUST BE FIRST
# ============================================================================
# Check if gum is installed, if not install it and exit
check_gum() {
    if ! command -v gum &> /dev/null; then
        echo "⚠️  gum is not installed. Installing it now..."
        
        # Detect platform for gum installation
        if [[ "$(uname -s)" == "Linux" ]]; then
            if command -v pacman &> /dev/null; then
                # Arch Linux
                if command -v paru &> /dev/null; then
                    paru -S --noconfirm gum
                elif command -v yay &> /dev/null; then
                    yay -S --noconfirm gum
                else
                    echo "Please install paru or yay first, then run:"
                    echo "  paru -S gum"
                    echo "or"
                    echo "  yay -S gum"
                    exit 1
                fi
            elif command -v apt-get &> /dev/null; then
                # Debian/Ubuntu
                sudo apt-get update && sudo apt-get install -y gum
            else
                echo "Please install gum manually for your Linux distribution"
                exit 1
            fi
        elif [[ "$(uname -s)" == "Darwin" ]]; then
            # macOS
            if command -v brew &> /dev/null; then
                brew install gum
            else
                echo "Please install Homebrew first, then run:"
                echo "  brew install gum"
                exit 1
            fi
        else
            echo "Unknown platform. Please install gum manually."
            exit 1
        fi
        
        echo ""
        echo "✅ gum has been installed!"
        echo "Please run this script again: ./setup.sh"
        exit 0
    fi
}

# Check gum first, before anything else
check_gum

# Now we can use gum for all output
# ============================================================================
# PLATFORM DETECTION
# ============================================================================
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

# ============================================================================
# PRINT FUNCTIONS (using gum)
# ============================================================================
info() { gum style --foreground 12 "ℹ" "$1"; }
success() { gum style --foreground 10 "✓" "$1"; }
warning() { gum style --foreground 11 "⚠" "$1"; }
error() { gum style --foreground 9 "✗" "$1"; }
section() { 
    echo ""
    gum style --bold --foreground 12 "━━━ $1 ━━━"
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================
has_command() {
    command -v "$1" &> /dev/null
}

is_installed_arch() {
    if has_command paru; then
        paru -Qi "$1" &> /dev/null
    else
        pacman -Qi "$1" &> /dev/null 2>&1
    fi
}

is_installed_macos() {
    brew list "$1" &> /dev/null 2>&1
}

is_stowed() {
    local target="$1"
    local source="$2"
    if [[ -L "$target" ]] && [[ "$(readlink -f "$target")" == "$(readlink -f "$source")" ]]; then
        return 0
    fi
    return 1
}

# ============================================================================
# PACKAGE INSTALLATION
# ============================================================================
install_arch() {
    local pkg="$1"
    if has_command paru; then
        info "Installing $pkg with paru..."
        paru -S --noconfirm "$pkg"
    elif has_command yay; then
        info "Installing $pkg with yay..."
        yay -S --noconfirm "$pkg"
    else
        error "paru or yay not found! Please install one first:"
        echo "  git clone https://aur.archlinux.org/paru.git /tmp/paru"
        echo "  cd /tmp/paru && makepkg -si"
        exit 1
    fi
}

install_macos() {
    local pkg="$1"
    info "Installing $pkg with brew..."
    brew install "$pkg"
}

# ============================================================================
# EXA/EZA CONFLICT CHECK
# ============================================================================
check_exa_eza_conflict() {
    if ! has_command exa; then
        return 0  # No exa found, nothing to check
    fi
    
    # Check if exa is a symlink to eza (compatibility symlink from eza package)
    local exa_path
    exa_path=$(command -v exa)
    if [[ -L "$exa_path" ]]; then
        local link_target
        link_target=$(readlink -f "$exa_path" 2>/dev/null || readlink "$exa_path")
        if [[ "$link_target" == *"/eza" ]] || [[ "$(basename "$link_target")" == "eza" ]]; then
            # exa is a symlink to eza - this is fine, skip conflict check
            return 0
        fi
    fi
    
    # exa exists and is not a symlink to eza - check if it's installed via package manager
    local exa_installed=false
    if [[ "$PLATFORM" == "arch" ]]; then
        if is_installed_arch exa; then
            exa_installed=true
        fi
    elif [[ "$PLATFORM" == "macos" ]]; then
        if is_installed_macos exa; then
            exa_installed=true
        fi
    fi
    
    # Only warn if exa is actually installed via package manager
    if [[ "$exa_installed" == "true" ]]; then
        warning "exa is installed, but we use eza instead"
        if gum confirm "Remove exa and ensure eza is installed?"; then
            if [[ "$PLATFORM" == "arch" ]]; then
                info "Removing exa..."
                sudo pacman -Rns --noconfirm exa 2>/dev/null || paru -Rns --noconfirm exa 2>/dev/null || true
            elif [[ "$PLATFORM" == "macos" ]]; then
                info "Removing exa..."
                brew uninstall exa 2>/dev/null || true
            fi
            success "exa removed"
            
            # Ensure eza is installed
            if ! has_command eza; then
                info "Installing eza..."
                if [[ "$PLATFORM" == "arch" ]]; then
                    install_arch eza
                elif [[ "$PLATFORM" == "macos" ]]; then
                    install_macos eza
                fi
            fi
        else
            warning "Keeping exa, but aliases will use eza if available"
        fi
    fi
}

# ============================================================================
# CHECK PREREQUISITES
# ============================================================================
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
        if ! has_command paru && ! has_command yay; then
            error "paru or yay is not installed!"
            echo "  Install paru:"
            echo "    git clone https://aur.archlinux.org/paru.git /tmp/paru"
            echo "    cd /tmp/paru && makepkg -si"
            exit 1
        else
            success "AUR helper (paru/yay) is installed"
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
        if gum confirm "Install missing prerequisites?"; then
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

# ============================================================================
# CHECK STOWED PACKAGES
# ============================================================================
check_stowed() {
    section "Checking Dotfiles Installation"
    
    local dotfiles_dir
    dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local home_dir="$HOME"
    
    # Platform-aware package list
    # Common packages (installed on all platforms) should be checked on all platforms
    local packages=()
    
    # Common packages (available on all platforms)
    local common_stowed=(
        "ghostty:.config/ghostty"
        "tmux:.config/tmux"
        "yazi:.config/yazi"
        "starship:.config/starship.toml"
        "zsh:.zshrc"
        "mise:.config/mise/config.toml"
        "lazygit:.config/lazygit"
        "ssh:.ssh/dotfiles.conf"
    )
    
    if [[ "$PLATFORM" == "arch" ]]; then
        packages=(
            "${common_stowed[@]}"
            "bash:.bashrc"
            "hyprland:.config/hypr"
            "waybar:.config/waybar"
            "swaync:.config/swaync"
        )
    elif [[ "$PLATFORM" == "macos" ]]; then
        packages=(
            "${common_stowed[@]}"
            "nushell:.config/nushell"
        )
    else
        # Common packages for unknown platform
        packages=(
            "${common_stowed[@]}"
        )
    fi
    
    local not_stowed=()
    
    for package_info in "${packages[@]}"; do
        IFS=':' read -r package target <<< "$package_info"
        local package_dir="$dotfiles_dir/$package"
        local target_path="$home_dir/$target"
        
        # Check if package directory or target file exists in dotfiles
        if [[ -d "$package_dir" ]] || [[ -f "$package_dir/$target" ]]; then
            # Check if target is a symlink (file or directory)
            if [[ -L "$target_path" ]]; then
                local link_target
                link_target=$(readlink -f "$target_path" 2>/dev/null || readlink "$target_path")
                local expected_target
                expected_target=$(readlink -f "$package_dir/$target" 2>/dev/null || echo "$package_dir/$target")
                
                # Handle relative symlinks (like ../dotfiles/...)
                if [[ "$link_target" == *"$package_dir/$target"* ]] || [[ "$link_target" == "$expected_target" ]]; then
                    success "$package is stowed"
                elif [[ "$link_target" == *"$package"* ]] && [[ "$link_target" == *"$target"* ]]; then
                    # Check if symlink points to the package directory
                    success "$package is stowed"
                else
                    not_stowed+=("$package")
                    warning "$package is not stowed (target: $target)"
                fi
            # Check if target directory exists and contains the expected file (for directory stows)
            elif [[ -d "$target_path" ]] && [[ -f "$target_path/$(basename "$target")" ]]; then
                # Directory exists and contains the file - might be stowed as directory
                local parent_dir
                parent_dir=$(dirname "$target_path")
                local dir_name
                dir_name=$(basename "$target_path")
                if [[ -L "$parent_dir/$dir_name" ]]; then
                    success "$package is stowed"
                else
                    not_stowed+=("$package")
                    warning "$package is not stowed (target: $target)"
                fi
            else
                not_stowed+=("$package")
                warning "$package is not stowed (target: $target)"
            fi
        fi
    done
    
    if [[ ${#not_stowed[@]} -gt 0 ]]; then
        warning "Some packages are not stowed: ${not_stowed[*]}"
        info "Please stow them manually with: stow -t ~ <package-name>"
        info "For packages with existing files, use: stow -t ~ --adopt <package-name>"
    fi
}

# ============================================================================
# CHECK REQUIRED PACKAGES
# ============================================================================
check_packages() {
    section "Checking Required Packages"
    
    # Common packages (required for shell aliases and functionality)
    local common_packages=(
        "git"
        "stow"
        "mise"
        "tmux"
        "ghostty"
        "yazi"
        "zsh"        # Shell (has advanced configs in dotfiles)
        "eza"        # Enhanced ls replacement (used in bash/zsh)
        "nvim"       # Editor (aliased as vim in all shells)
        "gum"        # Beautiful CLI output (used by this script)
        "lazygit"    # Git TUI (aliased as lg)
        "fzf"        # Fuzzy finder (used in ff, ffn, ffc aliases)
        "fd"         # Fast file finder (used in ff, ffn aliases)
        "ripgrep"    # Fast grep (used in ffc alias, package name: ripgrep or rg)
        "ffmpegthumbnailer"  # Image thumbnail generation for yazi mediainfo plugin
        "cloudflared" # Cloudflare Tunnel (required for SSH homelab connection)
    )
    
    # Platform-specific packages for trash
    # macOS has built-in /usr/bin/trash, Linux needs trash-cli
    if [[ "$PLATFORM" == "arch" ]] || [[ "$PLATFORM" == "linux" ]]; then
        common_packages+=("trash-cli")  # Safe file operations (Linux only)
    fi
    
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
        # (none currently - zsh moved to common packages)
    )
    
    local missing=()
    
    # Check common packages
    for pkg in "${common_packages[@]}"; do
        # Handle ripgrep - command is 'rg' but package might be 'ripgrep'
        if [[ "$pkg" == "ripgrep" ]]; then
            if has_command rg; then
                success "ripgrep (rg) is installed"
            else
                missing+=("ripgrep")
                warning "ripgrep (rg) is not installed"
            fi
        # Handle trash-cli - command is 'trash' but package is 'trash-cli'
        elif [[ "$pkg" == "trash-cli" ]]; then
            if has_command trash; then
                success "trash-cli (trash) is installed"
            else
                missing+=("trash-cli")
                warning "trash-cli (trash) is not installed"
            fi
        else
            if has_command "$pkg"; then
                success "$pkg is installed"
            else
                missing+=("$pkg")
                warning "$pkg is not installed"
            fi
        fi
    done
    
    # Check trash command (platform-specific)
    if [[ "$PLATFORM" == "macos" ]]; then
        if has_command trash; then
            success "trash is available (macOS system command)"
        else
            warning "trash command not found (unexpected on macOS)"
        fi
    fi
    
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
        if [[ ${#macos_packages[@]} -gt 0 ]]; then
            for pkg in "${macos_packages[@]}"; do
                if is_installed_macos "$pkg" || has_command "$pkg"; then
                    success "$pkg is installed"
                else
                    missing+=("$pkg")
                    warning "$pkg is not installed"
                fi
            done
        fi
    fi
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        warning "Missing packages: ${missing[*]}"
        if gum confirm "Install missing packages?"; then
            for pkg in "${missing[@]}"; do
                # Handle package name variations
                local install_pkg="$pkg"
                if [[ "$pkg" == "ripgrep" ]]; then
                    # On Arch, package is 'ripgrep', on macOS it's 'ripgrep' via brew
                    install_pkg="ripgrep"
                fi
                
                if [[ "$PLATFORM" == "arch" ]]; then
                    install_arch "$install_pkg"
                elif [[ "$PLATFORM" == "macos" ]]; then
                    install_macos "$install_pkg"
                fi
            done
            success "All packages installed"
        fi
    fi
}

# ============================================================================
# CHECK MISE SETUP
# ============================================================================
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
        if gum confirm "Install Ruby with mise?"; then
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

# ============================================================================
# CHECK SHELL CONFIGURATION
# ============================================================================
check_shell() {
    section "Checking Shell Configuration"
    
    local shell_name
    shell_name=$(basename "$SHELL")
    
    # Check shell configuration - we respect the system's default shell
    if [[ "$PLATFORM" == "arch" ]] || [[ "$PLATFORM" == "linux" ]]; then
        if [[ -f "$HOME/.bashrc" ]] && grep -q "bashrc" "$HOME/.bashrc"; then
            success "Bash configuration is set up"
        else
            warning "Bash configuration may not be complete"
        fi
    elif [[ "$PLATFORM" == "macos" ]]; then
        if [[ -f "$HOME/.zshrc" ]]; then
            success "Zsh configuration is set up"
        else
            warning "Zsh configuration may not be complete"
        fi
    fi
    
    info "Current shell: $shell_name (system default: $SHELL)"
    info "All tools (tmux, ghostty, etc.) respect the system's default shell"
}

# ============================================================================
# CHECK WAYLAND SETUP (Arch only)
# ============================================================================
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

# ============================================================================
# CHECK GIT FILTER CONFIGURATION
# ============================================================================
check_git_filter() {
    section "Checking Git Filter Configuration"
    
    local dotfiles_dir
    dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Check if we're in the dotfiles repository
    if [[ ! -d "$dotfiles_dir/.git" ]]; then
        info "Not in a git repository, skipping git filter setup"
        return 0
    fi
    
    # Check if git filter is configured
    if git config --get filter.empty-content.clean &> /dev/null; then
        success "Git empty-content filter is configured"
    else
        warning "Git empty-content filter is not configured"
        if gum confirm "Configure git filter for optional AI config files?"; then
            git config filter.empty-content.clean 'cat /dev/null'
            git config filter.empty-content.smudge 'cat'
            success "Git filter configured"
            info "This ensures optional AI config files are tracked as empty in git"
        fi
    fi
}

# ============================================================================
# MAIN FUNCTION
# ============================================================================
main() {
    gum style --bold --foreground 12 "╔══════════════════════════════════════════════════════════╗"
    gum style --bold --foreground 12 "║         Dotfiles Setup & Verification Script            ║"
    gum style --bold --foreground 12 "╚══════════════════════════════════════════════════════════╝"
    echo ""
    
    info "Detected platform: $PLATFORM"
    
    if [[ "$PLATFORM" == "unknown" ]]; then
        error "Unknown platform. This script supports Arch Linux and macOS only."
        exit 1
    fi
    
    # Check for exa/eza conflict
    check_exa_eza_conflict
    
    check_prerequisites
    check_stowed
    check_packages
    check_mise
    check_shell
    check_git_filter
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
