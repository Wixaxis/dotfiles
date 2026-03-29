#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: package-run.sh <package-dir> [args...]" >&2
  exit 1
fi

PACKAGE_DIR="$1"
shift || true

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if command -v mise >/dev/null 2>&1; then
  exec mise exec ruby -- ruby "$ROOT/scripts/dotfiles.rb" --package-path "$PACKAGE_DIR" "$@"
fi

if ! command -v ruby >/dev/null 2>&1; then
  echo "ruby is required to run the metadata-driven package runner." >&2
  exit 1
fi

if ! ruby -e 'required = [3, 1]; current = RUBY_VERSION.split(".").first(2).map(&:to_i); exit((current <=> required) >= 0 ? 0 : 1)' >/dev/null 2>&1; then
  echo "ruby >= 3.1 is required to run the metadata-driven package runner. Install mise or a newer ruby." >&2
  exit 1
fi

exec ruby "$ROOT/scripts/dotfiles.rb" --package-path "$PACKAGE_DIR" "$@"
