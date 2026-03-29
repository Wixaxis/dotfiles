#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "stow-platform.sh is now a compatibility wrapper around ./setup.sh" >&2
exec "$ROOT/setup.sh" "$@"
