#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
PACKAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${DOTFILES_HOME:-$HOME}"
ENV_FILE="$HOME_DIR/.config/truenas-mount/truenas-smb.env"

"$ROOT/scripts/package-run.sh" "$PACKAGE_DIR" --generic-check

if [[ ! -f "$ENV_FILE" ]]; then
    echo "Missing local TrueNAS env file at $ENV_FILE" >&2
    exit 1
fi
