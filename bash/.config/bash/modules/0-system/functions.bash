# Custom functions

# Universal package update function
# Tries available package managers in order of preference
u() {
    # Try arch-update first (if available)
    if command -v arch-update &> /dev/null; then
        arch-update
        return $?
    fi
    
    # Try paru (AUR helper)
    if command -v paru &> /dev/null; then
        paru -Syu
        return $?
    fi
    
    # Try yay (AUR helper)
    if command -v yay &> /dev/null; then
        yay -Syu
        return $?
    fi
    
    # Try pacman (Arch Linux)
    if command -v pacman &> /dev/null; then
        sudo pacman -Syu
        return $?
    fi
    
    # Try brew (macOS)
    if command -v brew &> /dev/null; then
        brew update && brew upgrade -g
        return $?
    fi
    
    # No package manager found
    echo "Error: No supported package manager found (arch-update, paru, yay, pacman, or brew)" >&2
    return 1
}

# Universal package search function
# Tries available package managers in order of preference
# Usage: s <package-name>
# Unalias s if it exists (may be defined by oh-my-bash or other configs)
unalias s 2>/dev/null || true
s() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: s <package-name>" >&2
        return 1
    fi
    
    # Try paru (AUR helper)
    if command -v paru &> /dev/null; then
        paru -Ss "$@"
        return $?
    fi
    
    # Try yay (AUR helper)
    if command -v yay &> /dev/null; then
        yay -Ss "$@"
        return $?
    fi
    
    # Try pacman (Arch Linux)
    if command -v pacman &> /dev/null; then
        pacman -Ss "$@"
        return $?
    fi
    
    # Try brew (macOS)
    if command -v brew &> /dev/null; then
        brew search "$@"
        return $?
    fi
    
    # No package manager found
    echo "Error: No supported package manager found (paru, yay, pacman, or brew)" >&2
    return 1
}
