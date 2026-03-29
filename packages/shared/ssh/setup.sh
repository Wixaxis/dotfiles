#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
PACKAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${DOTFILES_HOME:-$HOME}"

ensure_include() {
    local ssh_dir="$HOME_DIR/.ssh"
    local ssh_config="$ssh_dir/config"
    local include_line='Include ~/.ssh/dotfiles.conf'

    mkdir -p "$ssh_dir"
    touch "$ssh_config"

    if grep -Eq '^[[:space:]]*Include[[:space:]]+~/.ssh/dotfiles\.conf([[:space:]]|$)' "$ssh_config"; then
        return 0
    fi

    local tmp_file
    tmp_file="$(mktemp)"
    printf '%s\n' "$include_line" > "$tmp_file"
    cat "$ssh_config" >> "$tmp_file"
    mv "$tmp_file" "$ssh_config"
}

case "${1:-apply}" in
    post_link)
        ensure_include
        ;;
    *)
        exec "$ROOT/scripts/package-run.sh" "$PACKAGE_DIR" "$@"
        ;;
esac
