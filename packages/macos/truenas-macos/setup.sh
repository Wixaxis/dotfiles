#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
PACKAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${DOTFILES_HOME:-$HOME}"
AUTO_YES="${DOTFILES_YES:-}"

copy_env_example() {
    local config_dir="$HOME_DIR/.config/truenas-mount"
    local env_example="$config_dir/truenas-smb.env.example"
    local env_file="$config_dir/truenas-smb.env"

    mkdir -p "$config_dir"
    if [[ -f "$env_file" ]]; then
        return 0
    fi

    if [[ "$AUTO_YES" == "1" || "$AUTO_YES" == "true" || "$AUTO_YES" == "yes" ]]; then
        cp "$env_example" "$env_file"
        chmod 600 "$env_file"
        return 0
    fi

    if command -v gum >/dev/null 2>&1; then
        if gum confirm "Create ~/.config/truenas-mount/truenas-smb.env from the example file?"; then
            cp "$env_example" "$env_file"
            chmod 600 "$env_file"
        fi
        return 0
    fi

    echo "Create $env_file from $env_example before using the LaunchAgent." >&2
}

maybe_bootstrap_launch_agent() {
    [[ "${DOTFILES_OS:-}" == "macos" ]] || return 0
    command -v launchctl >/dev/null 2>&1 || return 0
    command -v gum >/dev/null 2>&1 || return 0
    [[ -t 1 ]] || return 0

    local plist="$HOME_DIR/Library/LaunchAgents/com.wixaxis.mount-truenas.plist"
    local domain="gui/$(id -u)"

    if gum confirm "Bootstrap the TrueNAS LaunchAgent now?"; then
        launchctl bootstrap "$domain" "$plist" 2>/dev/null || true
        launchctl kickstart -k "$domain/com.wixaxis.mount-truenas" 2>/dev/null || true
    fi
}

case "${1:-apply}" in
    post_link)
        copy_env_example
        maybe_bootstrap_launch_agent
        ;;
    *)
        exec "$ROOT/scripts/package-run.sh" "$PACKAGE_DIR" "$@"
        ;;
esac
