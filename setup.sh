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

# Desktop detection (Linux only): gnome | hyprland | other
# Used to stow/install only packages that make sense for the DE
DESKTOP=""
if [[ "$PLATFORM" == "arch" ]] || [[ "$PLATFORM" == "linux" ]]; then
    if [[ "${XDG_CURRENT_DESKTOP:-}" == *"GNOME"* ]] || [[ "${XDG_SESSION_DESKTOP:-}" == *"gnome"* ]]; then
        DESKTOP="gnome"
    elif [[ -n "${HYPRLAND_INSTANCE:-}" ]] || [[ "${XDG_CURRENT_DESKTOP:-}" == *"Hyprland"* ]]; then
        DESKTOP="hyprland"
    else
        DESKTOP="other"
    fi
fi

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

canonical_path() {
    local path="$1"

    if [[ ! -e "$path" ]] && [[ ! -L "$path" ]]; then
        return 1
    fi

    realpath "$path" 2>/dev/null
}

is_target_stowed() {
    local target="$1"
    local source="$2"
    local target_real
    local source_real

    target_real=$(canonical_path "$target") || return 1
    source_real=$(canonical_path "$source") || return 1

    # Fast path: check if it's a proper symlink
    if [[ "$target_real" == "$source_real" ]]; then
        return 0
    fi

    # If target exists but isn't a symlink to source, check if content matches
    if [[ -e "$target" ]] && [[ -e "$source" ]]; then
        if [[ -d "$target" ]] && [[ -d "$source" ]]; then
            # Compare directory contents recursively
            if compare_directories "$source" "$target"; then
                return 0
            fi
        elif [[ -f "$target" ]] && [[ -f "$source" ]]; then
            # Compare single files by size and hash
            if compare_files "$source" "$target"; then
                return 0
            fi
        fi
    fi

    return 1
}

# Compare two directories for identical content (files and sizes)
compare_directories() {
    local source_dir="$1"
    local target_dir="$2"

    # Check if source exists
    if [[ ! -d "$source_dir" ]]; then
        return 1
    fi

    # Check if target exists
    if [[ ! -d "$target_dir" ]]; then
        return 1
    fi

    # Build file lists (relative paths)
    local source_files target_files
    source_files=$(find "$source_dir" -type f 2>/dev/null | sed "s|^$source_dir/||" | sort)
    target_files=$(find "$target_dir" -type f 2>/dev/null | sed "s|^$target_dir/||" | sort)

    # Quick check: same number of files
    local source_count target_count
    source_count=$(echo "$source_files" | grep -c '^' 2>/dev/null || echo 0)
    target_count=$(echo "$target_files" | grep -c '^' 2>/dev/null || echo 0)

    if [[ "$source_count" -ne "$target_count" ]]; then
        return 1
    fi

    # Check: same file list
    if [[ "$source_files" != "$target_files" ]]; then
        return 1
    fi

    # Compare file sizes for each file (faster than hashing)
    local file
    while IFS= read -r file; do
        if [[ -z "$file" ]]; then
            continue
        fi

        local source_file="$source_dir/$file"
        local target_file="$target_dir/$file"

        # Check if both are files
        if [[ ! -f "$source_file" ]] || [[ ! -f "$target_file" ]]; then
            return 1
        fi

        # Compare sizes
        local source_size target_size
        source_size=$(stat -c%s "$source_file" 2>/dev/null || stat -f%z "$source_file" 2>/dev/null)
        target_size=$(stat -c%s "$target_file" 2>/dev/null || stat -f%z "$target_file" 2>/dev/null)

        if [[ "$source_size" != "$target_size" ]]; then
            return 1
        fi
    done <<< "$source_files"

    return 0
}

# Compare two files for equality
compare_files() {
    local source_file="$1"
    local target_file="$2"

    # Check both exist and are files
    [[ -f "$source_file" ]] || return 1
    [[ -f "$target_file" ]] || return 1

    # Compare sizes first (fast)
    local source_size target_size
    source_size=$(stat -c%s "$source_file" 2>/dev/null || stat -f%z "$source_file" 2>/dev/null)
    target_size=$(stat -c%s "$target_file" 2>/dev/null || stat -f%z "$target_file" 2>/dev/null)

    if [[ "$source_size" != "$target_size" ]]; then
        return 1
    fi

    # Same size - compare content with md5sum
    local source_hash target_hash
    source_hash=$(md5sum "$source_file" 2>/dev/null | cut -d' ' -f1)
    target_hash=$(md5sum "$target_file" 2>/dev/null | cut -d' ' -f1)

    [[ "$source_hash" == "$target_hash" ]]
}

backup_path() {
    local path="$1"
    local timestamp
    timestamp=$(date +"%Y%m%d-%H%M%S")
    echo "${path}.pre-dotfiles-${timestamp}"
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

is_brew_formula_installed() {
    brew list --formula "$1" &> /dev/null 2>&1
}

is_brew_cask_installed() {
    brew list --cask "$1" &> /dev/null 2>&1
}

install_macos_formula() {
    local pkg="$1"
    info "Installing $pkg with brew..."
    brew install "$pkg"
}

install_macos_cask() {
    local pkg="$1"
    info "Installing $pkg with brew cask..."
    brew install --cask "$pkg"
}

stow_package() {
    local dotfiles_dir="$1"
    local package="$2"
    local target="$3"
    local target_path="$HOME/$target"

    if stow -d "$dotfiles_dir" -t "$HOME" "$package"; then
        success "$package stowed successfully"
        return 0
    fi

    if [[ -e "$target_path" ]] || [[ -L "$target_path" ]]; then
        local backup_target
        backup_target=$(backup_path "$target_path")
        warning "Backing up conflicting target: $target_path -> $backup_target"
        mkdir -p "$(dirname "$backup_target")"
        mv "$target_path" "$backup_target"

        if stow -d "$dotfiles_dir" -t "$HOME" "$package"; then
            success "$package stowed successfully"
            return 0
        fi
    fi

    error "Failed to stow $package"
    info "You may need to stow it manually: cd $dotfiles_dir && stow -t ~ $package"
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
    install_macos_formula "$pkg"
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
        "fastfetch:.config/fastfetch"
        "ghostty:.config/ghostty"
        "glow:.config/glow"
        "lazygit:.config/lazygit"
        "justfile:justfile"
        "mise:.config/mise"
        "neovide:.config/neovide"
        "scripts:scripts"
        "ssh:.ssh/dotfiles.conf"
        "starship:.config/starship.toml"
        "tmux:.config/tmux"
        "tmuxinator:.config/tmuxinator"
        "yazi:.config/yazi"
        "zed:.config/zed"
    )
    
    if [[ "$PLATFORM" == "arch" ]] || [[ "$PLATFORM" == "linux" ]]; then
        packages=(
            "${common_stowed[@]}"
            "bash:.bashrc"
            "nushell:.config/nushell"
            "vicinae:.config/vicinae"
        )
        if [[ "$DESKTOP" == "hyprland" ]]; then
            packages+=(
                "hyprland:.config/hypr"
                "waybar:.config/waybar"
                "swaync:.config/swaync"
            )
        fi
    elif [[ "$PLATFORM" == "macos" ]]; then
        packages=(
            "${common_stowed[@]}"
            "nushell:Library/Application Support/nushell"
            "truenas-macos:Library/LaunchAgents/com.wixaxis.mount-truenas.plist"
            "zsh:.zshrc"
        )
    else
        packages=(
            "${common_stowed[@]}"
        )
    fi
    
    local not_stowed=()
    local content_matches_not_stowed=()
    
    for package_info in "${packages[@]}"; do
        IFS=':' read -r package target <<< "$package_info"
        local package_dir="$dotfiles_dir/$package"
        local target_path="$home_dir/$target"
        local source_path="$package_dir/$target"

        # Check if package directory or target file exists in dotfiles
        if [[ -d "$package_dir" ]] || [[ -f "$source_path" ]] || [[ -d "$source_path" ]]; then
            # Check if properly symlinked first
            local target_real source_real
            target_real=$(canonical_path "$target_path") || target_real=""
            source_real=$(canonical_path "$source_path") || source_real=""
            
            if [[ "$target_real" == "$source_real" ]] && [[ -n "$target_real" ]]; then
                # Properly symlinked
                success "$package is stowed"
            elif is_target_stowed "$target_path" "$source_path"; then
                # Content matches but not symlinked
                content_matches_not_stowed+=("$package:$target")
                warning "$package content matches but is not symlinked (target: $target)"
            else
                # Not stowed and content doesn't match
                not_stowed+=("$package")
                warning "$package is not stowed (target: $target)"
                # Debug info
                if [[ -e "$target_path" ]]; then
                    info "  Debug: Target exists at $target_path"
                    if [[ -d "$target_path" ]]; then
                        local file_count
                        file_count=$(find "$target_path" -type f 2>/dev/null | wc -l)
                        info "  Debug: Target is directory with $file_count files"
                    fi
                else
                    info "  Debug: Target does not exist at $target_path"
                fi
                if [[ -d "$package_dir" ]]; then
                    local source_file_count
                    source_file_count=$(find "$package_dir" -type f 2>/dev/null | wc -l)
                    info "  Debug: Source package has $source_file_count files"
                fi
            fi
        fi
    done
    
    # Handle packages that need to be stowed (missing or different content)
    if [[ ${#not_stowed[@]} -gt 0 ]]; then
        warning "Some packages are not stowed: ${not_stowed[*]}"
        
        for package in "${not_stowed[@]}"; do
            local target=""
            for package_info in "${packages[@]}"; do
                IFS=':' read -r candidate_package candidate_target <<< "$package_info"
                if [[ "$candidate_package" == "$package" ]]; then
                    target="$candidate_target"
                    break
                fi
            done

            if gum confirm "Stow $package now?"; then
                info "Stowing $package..."
                if stow_package "$dotfiles_dir" "$package" "$target"; then
                    # Verify it was actually stowed
                    if is_target_stowed "$HOME/$target" "$dotfiles_dir/$package/$target"; then
                        success "$package is now properly stowed"
                    else
                        error "Stow reported success but $package is still not detected as stowed"
                        info "Target: $HOME/$target"
                        info "Source: $dotfiles_dir/$package/$target"
                        if [[ -e "$HOME/$target" ]]; then
                            info "Target exists: yes"
                            if [[ -L "$HOME/$target" ]]; then
                                info "Target is symlink: yes -> $(readlink "$HOME/$target")"
                            else
                                info "Target is symlink: no"
                                info "Target type: directory"
                            fi
                        else
                            info "Target exists: no"
                        fi
                    fi
                else
                    error "Failed to stow $package"
                fi
            fi
        done
    fi
    
    # Handle packages where content matches but isn't symlinked
    if [[ ${#content_matches_not_stowed[@]} -gt 0 ]]; then
        echo ""
        info "Some packages have matching content but aren't symlinked:"
        for pkg_info in "${content_matches_not_stowed[@]}"; do
            IFS=':' read -r pkg_name pkg_target <<< "$pkg_info"
            echo "  - $pkg_name (~/$pkg_target)"
        done
        echo ""
        
        if gum confirm "Replace these with symlinks to dotfiles?"; then
            for pkg_info in "${content_matches_not_stowed[@]}"; do
                IFS=':' read -r pkg_name pkg_target <<< "$pkg_info"
                local full_target="$home_dir/$pkg_target"
                
                info "Converting $pkg_name to symlink..."
                
                # Backup existing directory/file
                if [[ -e "$full_target" ]] || [[ -L "$full_target" ]]; then
                    local backup_path="${full_target}.backup.$(date +%Y%m%d_%H%M%S)"
                    mv "$full_target" "$backup_path"
                    info "Backed up to: $backup_path"
                fi
                
                # Stow the package
                stow_package "$dotfiles_dir" "$pkg_name" "$pkg_target"
            done
            success "All packages converted to symlinks"
        fi
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
        "tmuxinator"
        "ghostty"
        "yazi"
        "zsh"        # Shell (has advanced configs in dotfiles)
        "eza"        # Enhanced ls replacement (used in bash/zsh)
        "nvim"       # Editor (aliased as vim in all shells)
        "gum"        # Beautiful CLI output (used by this script)
        "glow"       # Markdown viewer
        "just"       # Task runner
        "lazygit"    # Git TUI (aliased as lg)
        "fastfetch"  # Fast system info display (used in tmuxinator and tmux sessions)
        "fzf"        # Fuzzy finder (used in ff, ffn, ffc aliases)
        "fd"         # Fast file finder (used in ff, ffn aliases)
        "ripgrep"    # Fast grep (used in ffc alias, package name: ripgrep or rg)
        "ffmpegthumbnailer"  # Image thumbnail generation for yazi mediainfo plugin
        "cloudflared" # Cloudflare Tunnel (required for SSH homelab connection)
        "starship"   # Prompt used by shell configs
    )
    
    # Platform-specific packages for trash
    # macOS has built-in /usr/bin/trash, Linux needs trash-cli
    if [[ "$PLATFORM" == "arch" ]] || [[ "$PLATFORM" == "linux" ]]; then
        common_packages+=("trash-cli")  # Safe file operations (Linux only)
    fi
    
    # Arch packages: DE-agnostic vs Hyprland-only
    local arch_common=(
        "bash"
        "btop"
        "starship"
        "noto-fonts"
        "noto-fonts-cjk"
        "noto-fonts-emoji"
        "noto-fonts-extra"
        "xdg-desktop-portal"
        "flameshot"
        "papirus-icon-theme"
        "nordzy-icon-theme"
        "tela-icon-theme"
    )
    local arch_hyprland=(
        "hyprland"
        "waybar"
        "swaync"
        "hypridle"
        "hyprlock"
        "hyprpolkitagent"
        "rofi"
        "xdg-desktop-portal-hyprland"
    )
    
    # macOS-specific packages
    local macos_packages=(
        "nushell"
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
        elif [[ "$pkg" == "tmuxinator" ]]; then
            if has_command tmuxinator; then
                success "tmuxinator is installed"
            else
                missing+=("tmuxinator")
                warning "tmuxinator is not installed"
            fi
        elif [[ "$pkg" == "ghostty" ]]; then
            if has_command ghostty || is_brew_cask_installed ghostty; then
                success "ghostty is installed"
            else
                missing+=("ghostty")
                warning "ghostty is not installed"
            fi
        elif [[ "$pkg" == "just" ]]; then
            if has_command just; then
                success "just is installed"
            else
                missing+=("just")
                warning "just is not installed"
            fi
        elif [[ "$pkg" == "glow" ]]; then
            if has_command glow; then
                success "glow is installed"
            else
                missing+=("glow")
                warning "glow is not installed"
            fi
        elif [[ "$pkg" == "starship" ]]; then
            if has_command starship; then
                success "starship is installed"
            else
                missing+=("starship")
                warning "starship is not installed"
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
    
    # Check platform-specific packages
    if [[ "$PLATFORM" == "arch" ]]; then
        for pkg in "${arch_common[@]}"; do
            if is_installed_arch "$pkg" || has_command "$pkg"; then
                success "$pkg is installed"
            else
                missing+=("$pkg")
                warning "$pkg is not installed"
            fi
        done
        if [[ "$DESKTOP" == "hyprland" ]]; then
            for pkg in "${arch_hyprland[@]}"; do
                if is_installed_arch "$pkg" || has_command "$pkg"; then
                    success "$pkg is installed"
                else
                    missing+=("$pkg")
                    warning "$pkg is not installed"
                fi
            done
        fi
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
                    case "$install_pkg" in
                        ghostty)
                            install_macos_cask ghostty
                            ;;
                        *)
                            install_macos_formula "$install_pkg"
                            ;;
                    esac
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

    if mise current &> /dev/null; then
        local missing_tools
        missing_tools=$(mise current 2>/dev/null | awk '$2 == "MISSING" {print $1}')
        if [[ -n "$missing_tools" ]]; then
            warning "Some mise tools from the repo config are missing"
            if gum confirm "Install all tools from mise config now?"; then
                mise install
                success "mise tools installed"
            fi
        else
            success "All tools from mise config are installed"
        fi
    fi
    
    # Check if mise activation is present in the active shell config
    local shell_name
    shell_name=$(basename "${SHELL:-}")

    if [[ "$shell_name" == "zsh" ]]; then
        if grep -qs 'mise activate zsh' "$HOME/.zshrc" 2>/dev/null || grep -Rqs 'mise activate zsh' "$HOME/.config/zsh" 2>/dev/null; then
            success "mise is activated in shell"
        else
            warning "mise may not be activated in your shell"
            info 'Make sure you have: eval "$(mise activate zsh)" in your shell config'
        fi
    elif [[ "$shell_name" == "bash" ]]; then
        if grep -qs 'mise activate bash' "$HOME/.bashrc" 2>/dev/null || grep -Rqs 'mise activate bash' "$HOME/.config/bash" 2>/dev/null; then
            success "mise is activated in shell"
        else
            warning "mise may not be activated in your shell"
            info 'Make sure you have: eval "$(mise activate bash)" in your shell config'
        fi
    else
        if [[ -n "${MISE_SHELL:-}" ]]; then
            success "mise is activated in shell"
        else
            warning "mise activation could not be verified for shell: $shell_name"
        fi
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
# CHECK WAYLAND SETUP (Arch only; Hyprland-specific checks when on Hyprland)
# ============================================================================
check_wayland() {
    if [[ "$PLATFORM" != "arch" ]] && [[ "$PLATFORM" != "linux" ]]; then
        return 0
    fi
    
    section "Checking Wayland Setup"
    
    if [[ -n "${WAYLAND_DISPLAY:-}" ]] || [[ "${XDG_SESSION_TYPE:-}" == "wayland" ]]; then
        success "Running on Wayland"
        if [[ "$DESKTOP" == "gnome" ]]; then
            info "GNOME session detected (no Hyprland-specific checks)"
        elif [[ "$DESKTOP" == "hyprland" ]]; then
            if systemctl --user is-active --quiet hyprpolkitagent.service 2>/dev/null; then
                success "hyprpolkitagent service is running"
            else
                warning "hyprpolkitagent service is not running"
                info "Start it with: systemctl --user enable --now hyprpolkitagent.service"
            fi
            if [[ -f "$HOME/.config/qt6ct/qt6ct.conf" ]]; then
                success "qt6ct is configured"
            else
                warning "qt6ct is not configured"
                info "Configure it with: qt6ct"
            fi
        fi
    else
        info "Not running on Wayland (or not in Wayland session)"
    fi
}

# ============================================================================
# CHECK ARCH-SPECIFIC SERVICES (pacman hooks, mirror updates)
# ============================================================================
check_arch_services() {
    if [[ "$PLATFORM" != "arch" ]]; then
        return 0
    fi
    
    section "Checking Arch Linux Services"
    
    local dotfiles_dir
    dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Check and install pacman hooks
    info "Checking pacman hooks..."
    if [[ -f "/etc/pacman.d/hooks/pacnew.hook" ]]; then
        success "Pacnew handler hook is installed"
    else
        warning "Pacnew handler hook is not installed"
        if gum confirm "Install pacman hook to auto-handle .pacnew files?"; then
            if [[ -f "$dotfiles_dir/arch-update/.config/pacman/hooks/pacnew.hook" ]]; then
                sudo mkdir -p /etc/pacman.d/hooks/bin
                sudo cp "$dotfiles_dir/arch-update/.config/pacman/hooks/pacnew.hook" /etc/pacman.d/hooks/
                sudo cp "$dotfiles_dir/arch-update/.config/pacman/hooks.bin/pacnew-handler.sh" /etc/pacman.d/hooks/bin/
                sudo chmod +x /etc/pacman.d/hooks/bin/pacnew-handler.sh
                success "Pacnew handler hook installed"
            else
                error "Pacnew hook files not found in dotfiles"
            fi
        fi
    fi
    
    # Check and setup reflector timer
    info "Checking mirror update service..."
    if systemctl list-timers reflector-update.timer &> /dev/null || \
       systemctl list-unit-files | grep -q "reflector-update.timer"; then
        success "Reflector timer is configured"
        systemctl --user list-timers reflector-update.timer 2>/dev/null || \
        systemctl list-timers reflector-update.timer 2>/dev/null || \
        info "Timer details not available (may need to check manually)"
    else
        warning "Reflector timer is not configured"
        if gum confirm "Setup automatic weekly mirror list updates?"; then
            # Copy user service files
            mkdir -p "$HOME/.config/systemd/user"
            if [[ -f "$dotfiles_dir/arch-update/.config/systemd/user/reflector-update.service" ]]; then
                cp "$dotfiles_dir/arch-update/.config/systemd/user/reflector-update.service" \
                   "$HOME/.config/systemd/user/"
                cp "$dotfiles_dir/arch-update/.config/systemd/user/reflector-update.timer" \
                   "$HOME/.config/systemd/user/"
                
                # Reload daemon and enable timer
                systemctl --user daemon-reload
                systemctl --user enable reflector-update.timer
                systemctl --user start reflector-update.timer
                success "Reflector timer installed and started"
                info "Mirror list will be updated weekly"
            else
                error "Reflector service files not found in dotfiles"
            fi
        fi
    fi
    
    # Check if mirrorlist needs immediate update
    if [[ -f "/etc/pacman.d/mirrorlist" ]]; then
        local mirrorlist_age
        mirrorlist_age=$(( ($(date +%s) - $(stat -c %Y /etc/pacman.d/mirrorlist 2>/dev/null || echo "0")) / 86400 ))
        if [[ $mirrorlist_age -gt 30 ]]; then
            warning "Mirror list is ${mirrorlist_age} days old"
            if gum confirm "Update mirror list now?"; then
                if systemctl --user is-active reflector-update.service &> /dev/null || \
                   systemctl is-active reflector-update.service &> /dev/null 2>&1; then
                    info "Reflector service is already running or timer is active"
                else
                    sudo reflector --latest 30 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
                    success "Mirror list updated"
                fi
            fi
        else
            success "Mirror list is ${mirrorlist_age} days old (up to date)"
        fi
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
    
    info "Detected platform: $PLATFORM${DESKTOP:+ (desktop: $DESKTOP)}"
    
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
    check_arch_services
    
    section "Setup Complete"
    success "All checks completed!"
    info "You may need to restart your shell or log out/in for some changes to take effect"
    
    if [[ "$PLATFORM" == "arch" ]] && [[ "$DESKTOP" == "hyprland" ]]; then
        info "For Hyprland, you may want to run:"
        echo "  hyprctl reload"
        echo "  systemctl --user restart hyprpolkitagent"
    fi
}

# Run main function
main
