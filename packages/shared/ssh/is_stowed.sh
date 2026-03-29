#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
PACKAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${DOTFILES_HOME:-$HOME}"
SSH_CONFIG="$HOME_DIR/.ssh/config"

"$ROOT/scripts/package-run.sh" "$PACKAGE_DIR" --generic-check

if [[ ! -f "$SSH_CONFIG" ]]; then
    echo "Missing SSH config at $SSH_CONFIG" >&2
    exit 1
fi

if ! grep -Eq '^[[:space:]]*Include[[:space:]]+~/.ssh/dotfiles\.conf([[:space:]]|$)' "$SSH_CONFIG"; then
    echo "Missing Include ~/.ssh/dotfiles.conf in $SSH_CONFIG" >&2
    exit 1
fi
