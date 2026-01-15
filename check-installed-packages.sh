#!/bin/bash
# Check which dotfile packages have configs but aren't installed
# This script can be run to audit your dotfiles

# Note: Archived packages (dunst, kitty, kvantum, qimgv) are excluded
PACKAGES=(
    "arch-update:arch-update"
    "bash:bash"
    "btop:btop"
    "ghostty:ghostty"
    "mise:mise"
    "qt6ct:qt6ct"
    "hyprland:hyprland"
    "hyprpanel:hyprpanel"
    "justfile:just"
    "lazygit:lazygit"
    "neofetch:neofetch"
    "neovide:neovide"
    "nushell:nu"
    "rofi:rofi"
    "solaar:solaar"
    "starship:starship"
    "swaync:swaync-client"
    "tmux:tmux"
    "tmuxinator:tmuxinator"
    "waybar:waybar"
    "yazi:yazi"
    "zsh:zsh"
)

echo "=== Checking installed packages ==="
echo ""

INSTALLED=()
NOT_INSTALLED=()
MAYBE_INSTALLED=()

for entry in "${PACKAGES[@]}"; do
    IFS=':' read -r config_name binary_name <<< "$entry"
    
    # Check if binary exists
    if command -v "$binary_name" &> /dev/null; then
        INSTALLED+=("$config_name")
        echo "✓ $config_name ($binary_name) - INSTALLED"
    else
        # Special checks for services/daemons
        case "$config_name" in
            dunst)
                if systemctl --user is-active --quiet dunst 2>/dev/null || pgrep -x dunst > /dev/null 2>&1; then
                    MAYBE_INSTALLED+=("$config_name (running as service)")
                    echo "? $config_name - RUNNING AS SERVICE (but binary not in PATH)"
                else
                    NOT_INSTALLED+=("$config_name")
                    echo "✗ $config_name ($binary_name) - NOT INSTALLED"
                fi
                ;;
            swaync)
                if command -v swaync-client &> /dev/null || pgrep -x swaync > /dev/null 2>&1; then
                    MAYBE_INSTALLED+=("$config_name (client available or service running)")
                    echo "? $config_name - CLIENT/SERVICE AVAILABLE"
                else
                    NOT_INSTALLED+=("$config_name")
                    echo "✗ $config_name ($binary_name) - NOT INSTALLED"
                fi
                ;;
            kitty|qimgv|kvantum)
                # Check if installed via package manager
                if pacman -Qq "$config_name" &> /dev/null 2>&1; then
                    MAYBE_INSTALLED+=("$config_name (installed via pacman but not in PATH)")
                    echo "? $config_name - INSTALLED VIA PACMAN (but not in PATH)"
                elif flatpak list --app 2>/dev/null | grep -qi "$config_name"; then
                    MAYBE_INSTALLED+=("$config_name (installed via flatpak)")
                    echo "? $config_name - INSTALLED VIA FLATPAK"
                else
                    NOT_INSTALLED+=("$config_name")
                    echo "✗ $config_name ($binary_name) - NOT INSTALLED"
                fi
                ;;
            *)
                NOT_INSTALLED+=("$config_name")
                echo "✗ $config_name ($binary_name) - NOT INSTALLED"
                ;;
        esac
    fi
done

echo ""
echo "=== Summary ==="
echo "Installed: ${#INSTALLED[@]}"
echo "Maybe installed (service/flatpak/package manager): ${#MAYBE_INSTALLED[@]}"
echo "Not installed: ${#NOT_INSTALLED[@]}"
echo ""
echo "=== Packages with config but NOT INSTALLED ==="
for pkg in "${NOT_INSTALLED[@]}"; do
    echo "  - $pkg"
done

if [ ${#MAYBE_INSTALLED[@]} -gt 0 ]; then
    echo ""
    echo "=== Packages that might be installed (check manually) ==="
    for pkg in "${MAYBE_INSTALLED[@]}"; do
        echo "  - $pkg"
    done
fi
